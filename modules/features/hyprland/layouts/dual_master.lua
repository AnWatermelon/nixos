local M = {}

M.config = {
    enabled = true,
    main_monitor_name = nil,
    single_monitor_master_ratio = 0.55,
}

function M.set_main_monitor(name)
    M.config.main_monitor_name = name
end

function M.load_display_config()
    package.loaded["configs/display"] = nil
    local ok, display_cfg = pcall(require, "configs/display")
    if ok and type(display_cfg) == "table" then
        if display_cfg.main_monitor then
            M.config.main_monitor_name = display_cfg.main_monitor
        elseif display_cfg.main_monitor_name then
            M.config.main_monitor_name = display_cfg.main_monitor_name
        end
        if display_cfg.dual_master ~= nil then
            M.config.enabled = display_cfg.dual_master
        elseif display_cfg.enabled ~= nil then
            M.config.enabled = display_cfg.enabled
        end
    end
    if not M.config.main_monitor_name and _G.main_monitor then
        M.config.main_monitor_name = _G.main_monitor
    end
end

M.load_display_config()

function M.is_available()
    if M.config.enabled == false then
        return false
    end
    local topo = M.get_topology()
    return topo.count >= 2 and topo.secondary ~= nil
end

function M.get_topology()
    if not M.config.main_monitor_name then
        M.load_display_config()
    end

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
    local main_ws = topo.main.active_workspace
    if not sec_ws or not main_ws then return end

    if active_win.workspace and active_win.workspace.id == sec_ws.id then
        return
    end

    hl.dispatch(hl.dsp.window.move({
        workspace = sec_ws.id,
        silent = true,
        window = active_win,
    }))

    local remaining = M.get_workspace_windows(main_ws, "recent")
    if #remaining > 0 then
        hl.dispatch(hl.dsp.focus({ window = remaining[1] }))
    else
        hl.dispatch(hl.dsp.focus({ workspace = main_ws.id }))
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
    local slave_wins = M.get_workspace_windows(sec_ws, "stable")
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
        local slave_wins = M.get_workspace_windows(sec_ws, "stable")
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

local function should_remain_floating(win)
    if not win then return false end
    if win.tags then
        local tag_str = type(win.tags) == "table" and table.concat(win.tags, " ") or tostring(win.tags)
        if tag_str:find("file_chooser") or tag_str:find("settings") or tag_str:find("viewer") then
            return true
        end
    end
    local class = win.class or ""
    local title = win.title or ""
    if class:find("xdg%-desktop%-portal") or class:find("polkit") or class:find("pinentry") then
        return true
    end
    if title:find("Save As") or title:find("Save a File") or title:find("Pick Files") or title:find("Open Files") then
        return true
    end
    return false
end

local function handle_window_open(win)
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then return end

    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace
    if not main_ws or not sec_ws or main_ws.id == sec_ws.id then return end

    -- Re-fetch the live window to check its updated properties after rules have run
    local fresh_win = nil
    for _, w in ipairs(hl.get_windows()) do
        if w.address == win.address then
            fresh_win = w
            break
        end
    end

    if not fresh_win or not fresh_win.mapped or fresh_win.hidden then
        return
    end

    local ws_id = fresh_win.workspace and fresh_win.workspace.id
    local ws_name = fresh_win.workspace and fresh_win.workspace.name

    -- Check if this window was spawned by an application running on the slave monitor
    local is_child_of_slave = false
    if fresh_win.pid then
        local slave_wins = M.get_workspace_windows(sec_ws, "recent")
        for _, sw in ipairs(slave_wins) do
            if sw.pid and sw.pid == fresh_win.pid and sw.address ~= fresh_win.address then
                is_child_of_slave = true
                break
            end
        end
    end

    local is_on_sec = (ws_id == sec_ws.id or ws_name == sec_ws.name)
    local is_on_main = (ws_id == main_ws.id or ws_name == main_ws.name)

    -- If spawned by a slave application, it strictly belongs on the slave monitor.
    if is_child_of_slave then
        -- If Hyprland spawned it on the wrong monitor (e.g. main_ws), move it to sec_ws
        if not is_on_sec then
            hl.dispatch(hl.dsp.window.move({
                workspace = sec_ws.id,
                silent = false,
                window = fresh_win,
            }))
        end

        -- Ensure it doesn't fullscreen over the slave monitor
        if fresh_win.fullscreen and fresh_win.fullscreen ~= 0 then
            hl.dispatch(hl.dsp.window.fullscreen({
                mode = "fullscreen",
                action = "unset",
                window = fresh_win,
            }))
        end

        -- Unless it's an explicit modal dialog/picker, un-float it so it slots into dwindle
        if fresh_win.floating and not should_remain_floating(fresh_win) then
            hl.dispatch(hl.dsp.window.float({
                action = "unset",
                window = fresh_win,
            }))
        end

        hl.dispatch(hl.dsp.focus({ window = fresh_win }))
        return
    end

    -- If the window opened on the slave monitor directly
    if is_on_sec then
        if fresh_win.fullscreen and fresh_win.fullscreen ~= 0 then
            hl.dispatch(hl.dsp.window.fullscreen({
                mode = "fullscreen",
                action = "unset",
                window = fresh_win,
            }))
        end
        return
    end

    -- If the window is on main_ws (or targeted for main_ws)
    if not is_on_main and not ws_id then
        local cur_ws = hl.get_active_workspace()
        if cur_ws and (cur_ws.id == main_ws.id or cur_ws.name == main_ws.name) then
            is_on_main = true
        end
    end

    if is_on_main then
        if fresh_win.floating then
            return
        end

        local masters = M.get_workspace_windows(main_ws, "recent")
        local is_child_of_master = false
        if #masters > 0 and fresh_win.pid then
            for _, mw in ipairs(masters) do
                if mw.address ~= fresh_win.address and mw.pid and mw.pid == fresh_win.pid then
                    is_child_of_master = true
                    break
                end
            end
        end

        if is_child_of_master then
            -- Secondary window spawned by master app: move it to slave monitor
            hl.dispatch(hl.dsp.window.move({
                workspace = sec_ws.id,
                silent = false,
                window = fresh_win,
            }))
            hl.dispatch(hl.dsp.focus({ window = fresh_win }))
            return
        end

        -- New master application on main_ws: demote existing master window(s) to sec_ws
        for _, existing in ipairs(masters) do
            if existing.address ~= fresh_win.address then
                hl.dispatch(hl.dsp.window.move({
                    workspace = sec_ws.id,
                    silent = true,
                    window = existing,
                }))
            end
        end
        hl.dispatch(hl.dsp.focus({ window = fresh_win }))
    end
end

function M.on_window_open(win)
    if not win then return end

    if hl.timer then
        hl.timer(function()
            pcall(handle_window_open, win)
        end, { timeout = 25, type = "oneshot" })
    else
        pcall(handle_window_open, win)
    end
end

local function split_dwindle(area, n)
    if n <= 1 then return { area } end
    local a1, a2
    local n1 = math.ceil(n / 2)
    local n2 = math.floor(n / 2)
    if area.w >= area.h then
        if n == 3 then n1, n2 = 1, 2 end
        local w1 = math.floor(area.w / 2)
        a1 = { x = area.x, y = area.y, w = w1, h = area.h }
        a2 = { x = area.x + w1, y = area.y, w = area.w - w1, h = area.h }
    else
        if n == 3 then n1, n2 = 2, 1 end
        local h1 = math.floor(area.h / 2)
        a1 = { x = area.x, y = area.y, w = area.w, h = h1 }
        a2 = { x = area.x, y = area.y + h1, w = area.w, h = area.h - h1 }
    end
    local res1 = split_dwindle(a1, n1)
    local res2 = split_dwindle(a2, n2)
    local res = {}
    for _, b in ipairs(res1) do table.insert(res, b) end
    for _, b in ipairs(res2) do table.insert(res, b) end
    return res
end

local function tile_dwindle(targets, area)
    local n = #targets
    if n == 0 then return end
    if n == 1 then
        targets[1]:place(area)
        return
    end

    table.sort(targets, function(a, b)
        local aw = a.window
        local bw = b.window
        if aw and bw then
            return (aw.stable_id or 0) < (bw.stable_id or 0)
        end
        return (a.index or 0) < (b.index or 0)
    end)

    local boxes = split_dwindle(area, n)
    for i, target in ipairs(targets) do
        if boxes[i] then
            target:place(boxes[i])
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

        local slave_targets = {}
        for i = 2, n do
            table.insert(slave_targets, ctx.targets[i])
        end

        tile_dwindle(slave_targets, {
            x = slave_x,
            y = area.y,
            w = slave_w,
            h = area.h,
        })
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
        tile_dwindle(ctx.targets, area)
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

    is_available = function(self)
        return M.is_available()
    end,
    unavailable_reason = "Dual-Monitor Master requires at least 2 monitors",

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
                    hl.dispatch(hl.dsp.focus({ window = keep }))
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
