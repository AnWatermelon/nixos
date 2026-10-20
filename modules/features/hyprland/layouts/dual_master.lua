local M = {}

M.config = {
    main_monitor_name = nil,
    single_monitor_master_ratio = 0.55,
}

function M.get_topology()
    local monitors = hl.get_monitors()
    if #monitors == 0 then return { count = 0 } end

    local main_mon = nil
    local sec_mon = nil

    if M.config.main_monitor_name then
        for _, mon in ipairs(monitors) do
            if mon.name == M.config.main_monitor_name then
                main_mon = mon
                break
            end
        end
    end

    if not main_mon then
        for _, mon in ipairs(monitors) do
            if mon.x == 0 and mon.y == 0 then
                main_mon = mon
                break
            end
        end
    end

    if not main_mon then
        main_mon = monitors[1]
    end

    for _, mon in ipairs(monitors) do
        if mon.name ~= main_mon.name then
            sec_mon = mon
            break
        end
    end

    return {
        main = main_mon,
        secondary = sec_mon,
        count = #monitors,
    }
end

function M.get_workspace_windows(ws, sort_mode)
    if not ws then return {} end
    local ws_id = ws.id
    local ws_name = ws.name
    local wins = {}

    for _, w in ipairs(hl.get_windows()) do
        if not w.floating and w.mapped and not w.hidden then
            if w.workspace and (w.workspace.id == ws_id or w.workspace.name == ws_name) then
                table.insert(wins, w)
            end
        end
    end

    if sort_mode == "recent" then
        table.sort(wins, function(a, b)
            return (a.focus_history_id or 999) < (b.focus_history_id or 999)
        end)
    else
        table.sort(wins, function(a, b)
            local ay = (a.at and a.at.y) or 0
            local by = (b.at and b.at.y) or 0
            if math.abs(ay - by) > 10 then
                return ay < by
            end
            local ax = (a.at and a.at.x) or 0
            local bx = (b.at and b.at.x) or 0
            if ax ~= bx then
                return ax < bx
            end
            return (a.stable_id or 0) < (b.stable_id or 0)
        end)
    end

    return wins
end

function M.get_monitor_for_area(area)
    local monitors = hl.get_monitors()
    for _, mon in ipairs(monitors) do
        if area.x >= mon.x and area.x < (mon.x + mon.width)
           and area.y >= mon.y and area.y < (mon.y + mon.height) then
            return mon
        end
    end
    return monitors[1]
end

function M.shuffle()
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then
        hl.dispatch(hl.dsp.layout("swapwithmaster"))
        return
    end

    local active_win = hl.get_active_window()
    if not active_win then return end

    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace
    if not main_ws or not sec_ws then return end

    local is_on_main = (active_win.workspace and active_win.workspace.id == main_ws.id)

    if is_on_main then
        local slave_wins = M.get_workspace_windows(sec_ws, "recent")
        if #slave_wins > 0 then
            local next_slave = slave_wins[1]

            hl.dispatch(hl.dsp.window.move({
                workspace = sec_ws.id,
                silent = true,
                window = active_win,
            }))
            hl.dispatch(hl.dsp.window.move({
                workspace = main_ws.id,
                silent = false,
                window = next_slave,
            }))
            hl.dispatch(hl.dsp.focus({ window = next_slave }))
        else
            hl.notification.create({
                text = "No slave windows on secondary monitor",
                timeout = 1500,
            })
        end
    else
        local master_wins = M.get_workspace_windows(main_ws, "recent")
        if #master_wins > 0 then
            local old_master = master_wins[1]

            hl.dispatch(hl.dsp.window.move({
                workspace = sec_ws.id,
                silent = true,
                window = old_master,
            }))
        end

        hl.dispatch(hl.dsp.window.move({
            workspace = main_ws.id,
            silent = false,
            window = active_win,
        }))
        hl.dispatch(hl.dsp.focus({ window = active_win }))
    end
end

function M.promote()
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then
        hl.dispatch(hl.dsp.layout("focusmaster"))
        return
    end

    local active_win = hl.get_active_window()
    if not active_win then return end

    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace
    if not main_ws or not sec_ws then return end

    if active_win.workspace and active_win.workspace.id == main_ws.id then
        return
    end

    local master_wins = M.get_workspace_windows(main_ws, "recent")
    if #master_wins > 0 then
        hl.dispatch(hl.dsp.window.move({
            workspace = sec_ws.id,
            silent = true,
            window = master_wins[1],
        }))
    end

    hl.dispatch(hl.dsp.window.move({
        workspace = main_ws.id,
        silent = false,
        window = active_win,
    }))
    hl.dispatch(hl.dsp.focus({ window = active_win }))
end

function M.demote()
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then return end

    local active_win = hl.get_active_window()
    if not active_win then return end

    local sec_ws = topo.secondary.active_workspace
    if not sec_ws then return end

    if active_win.workspace and active_win.workspace.id == sec_ws.id then
        return
    end

    hl.dispatch(hl.dsp.window.move({
        workspace = sec_ws.id,
        silent = true,
        window = active_win,
    }))

    local main_ws = topo.main.active_workspace
    local remaining = M.get_workspace_windows(main_ws, "recent")
    if #remaining > 0 then
        hl.dispatch(hl.dsp.focus({ window = remaining[1] }))
    else
        hl.dispatch(hl.dsp.focus({ window = active_win }))
    end
end

function M.cycle_slaves(dir)
    dir = dir or 1
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then
        if dir > 0 then
            hl.dispatch(hl.dsp.layout("cyclenext"))
        else
            hl.dispatch(hl.dsp.layout("cycleprev"))
        end
        return
    end

    local sec_ws = topo.secondary.active_workspace
    local slave_wins = M.get_workspace_windows(sec_ws, "spatial")
    if #slave_wins == 0 then return end

    local active_win = hl.get_active_window()
    local cur_idx = nil
    for idx, w in ipairs(slave_wins) do
        if active_win and w.address == active_win.address then
            cur_idx = idx
            break
        end
    end

    local next_idx
    if not cur_idx then
        next_idx = (dir > 0) and 1 or #slave_wins
    else
        next_idx = ((cur_idx - 1 + dir) % #slave_wins) + 1
    end

    hl.dispatch(hl.dsp.focus({ window = slave_wins[next_idx] }))
end

function M.toggle_focus()
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then return end

    local active_win = hl.get_active_window()
    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace
    if not active_win or not main_ws or not sec_ws then return end

    if active_win.workspace and active_win.workspace.id == main_ws.id then
        local slave_wins = M.get_workspace_windows(sec_ws, "spatial")
        if #slave_wins > 0 then
            hl.dispatch(hl.dsp.focus({ window = slave_wins[1] }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = sec_ws.id }))
        end
    else
        local master_wins = M.get_workspace_windows(main_ws, "recent")
        if #master_wins > 0 then
            hl.dispatch(hl.dsp.focus({ window = master_wins[1] }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = main_ws.id }))
        end
    end
end

function M.on_window_open(win)
    if not win or win.floating then return end

    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then return end

    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace
    if not main_ws or not sec_ws then return end

    local is_on_main = false
    if win.workspace then
        is_on_main = (win.workspace.id == main_ws.id or win.workspace.name == main_ws.name)
    else
        local cur_ws = hl.get_active_workspace()
        if cur_ws and (cur_ws.id == main_ws.id or cur_ws.name == main_ws.name) then
            is_on_main = true
        end
    end

    if is_on_main then
        local masters = M.get_workspace_windows(main_ws, "recent")
        for _, existing in ipairs(masters) do
            if existing.address ~= win.address then
                hl.dispatch(hl.dsp.window.move({
                    workspace = sec_ws.id,
                    silent = true,
                    window = existing,
                }))
            end
        end
    end
end

local function recalculate(ctx)
    local n = #ctx.targets
    if n == 0 then return end

    local area = ctx.area
    local topo = M.get_topology()

    if topo.count < 2 or not topo.secondary then
        if n == 1 then
            ctx.targets[1]:place(area)
            return
        end

        local ratio = M.config.single_monitor_master_ratio or 0.55
        local master_w = math.floor(area.w * ratio)
        local slave_w = area.w - master_w
        local slave_x = area.x + master_w

        ctx.targets[1]:place({
            x = area.x,
            y = area.y,
            w = master_w,
            h = area.h,
        })

        local slave_count = n - 1
        local row_h = math.floor(area.h / slave_count)
        for i = 2, n do
            local s_idx = i - 1
            local y = area.y + (s_idx - 1) * row_h
            local h = (s_idx == slave_count) and (area.h - (s_idx - 1) * row_h) or row_h
            ctx.targets[i]:place({
                x = slave_x,
                y = y,
                w = slave_w,
                h = h,
            })
        end
        return
    end

    local target_mon = M.get_monitor_for_area(area)
    local is_main_monitor = (target_mon and target_mon.name == topo.main.name)

    if is_main_monitor then
        for _, target in ipairs(ctx.targets) do
            target:place({
                x = area.x,
                y = area.y,
                w = area.w,
                h = area.h,
            })
        end
    else
        if n == 1 then
            ctx.targets[1]:place(area)
        elseif n <= 3 then
            local row_h = math.floor(area.h / n)
            for i, target in ipairs(ctx.targets) do
                local y = area.y + (i - 1) * row_h
                local h = (i == n) and (area.h - (i - 1) * row_h) or row_h
                target:place({
                    x = area.x,
                    y = y,
                    w = area.w,
                    h = h,
                })
            end
        else
            local cols = 2
            local col_w = math.floor(area.w / cols)
            local rows = math.ceil(n / cols)
            local row_h = math.floor(area.h / rows)

            for i, target in ipairs(ctx.targets) do
                local c = (i - 1) % cols
                local r = math.floor((i - 1) / cols)

                local x = area.x + c * col_w
                local y = area.y + r * row_h
                local w = (c == cols - 1) and (area.w - (cols - 1) * col_w) or col_w
                local h = (r == rows - 1) and (area.h - (rows - 1) * row_h) or row_h

                target:place({
                    x = x,
                    y = y,
                    w = w,
                    h = h,
                })
            end
        end
    end
end

local function layout_msg(ctx, msg)
    if msg == "swap" or msg == "shuffle" then
        M.shuffle()
        return true
    elseif msg == "promote" then
        M.promote()
        return true
    elseif msg == "demote" then
        M.demote()
        return true
    elseif msg == "cyclenext" then
        M.cycle_slaves(1)
        return true
    elseif msg == "cycleprev" then
        M.cycle_slaves(-1)
        return true
    elseif msg == "togglefocus" then
        M.toggle_focus()
        return true
    end
    return false
end

local layout_definition = {
    name = "dual_master",
    display_name = "Dual-Monitor Master",
    engine = "lua:dual_master",

    init = function(self)
        hl.layout.register("dual_master", {
            recalculate = recalculate,
            layout_msg = layout_msg,
        })

        hl.on("window.open", function(win)
            local ok, mgr = pcall(require, "layouts/manager")
            if ok and mgr.get_active_layout() and mgr.get_active_layout().name == "dual_master" then
                pcall(M.on_window_open, win)
            end
        end)
    end,

    on_activate = function(self)
        local topo = M.get_topology()
        if topo.count >= 2 and topo.secondary then
            local main_ws = topo.main.active_workspace
            local sec_ws = topo.secondary.active_workspace
            if main_ws and sec_ws then
                local active_win = hl.get_active_window()
                local masters = M.get_workspace_windows(main_ws, "recent")
                if #masters > 1 then
                    local keep = active_win or masters[1]
                    for _, w in ipairs(masters) do
                        if w.address ~= keep.address then
                            hl.dispatch(hl.dsp.window.move({
                                workspace = sec_ws.id,
                                silent = true,
                                window = w,
                            }))
                        end
                    end
                end
            end
        end
    end,

    actions = {
        swap = M.shuffle,
        promote = M.promote,
        demote = M.demote,
        cycle_next = function() M.cycle_slaves(1) end,
        cycle_prev = function() M.cycle_slaves(-1) end,
        toggle_focus = M.toggle_focus,
    },
}

M.definition = layout_definition
return M
