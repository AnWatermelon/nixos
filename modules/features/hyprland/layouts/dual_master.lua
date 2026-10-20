-- layouts/dual_master.lua
-- Dual-Monitor Master layout for Hyprland.
-- Master window is kept on the main monitor (fullscreen / monocle style).
-- Slave windows are kept on the secondary monitor and tiled.
-- Provides quick shuffling between master and slave monitors.

local M = {}

-- Optional configuration overrides
M.config = {
    -- Name of main monitor, or nil to auto-detect (monitor at 0,0 or id 0)
    main_monitor_name = nil,
    -- Ratio for master width when falling back to a single monitor
    single_monitor_master_ratio = 0.55,
}

--- Get monitor topology (main monitor vs secondary monitor).
--- @return table { main: HL.Monitor, secondary: HL.Monitor|nil, count: integer }
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

--- Get non-floating, mapped windows for a given workspace.
--- Returns windows sorted by focus_history_id (0 = most recently focused).
--- @param ws HL.Workspace|nil
--- @return HL.Window[]
function M.get_workspace_windows(ws)
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

    table.sort(wins, function(a, b)
        return (a.focus_history_id or 999) < (b.focus_history_id or 999)
    end)

    return wins
end

--- Determine which monitor an area box belongs to.
--- @param area HL.Box
--- @return HL.Monitor|nil
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

-- ============================================
-- DUAL-MASTER ACTIONS & DISPATCHERS
-- ============================================

--- Core shuffle action:
--- - If focused on Main Monitor: pushes master to secondary monitor workspace,
---   and pulls the next slave from secondary to main monitor.
--- - If focused on Secondary Monitor: promotes the focused slave to main monitor
---   as master, and pushes the previous master to the secondary monitor.
function M.shuffle()
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then
        -- Single monitor fallback: standard swap with master
        hl.dispatch(hl.dsp.layout("swapwithmaster"))
        return
    end

    local active_win = hl.get_active_window()
    if not active_win then return end

    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace
    if not main_ws or not sec_ws then return end

    local master_wins = M.get_workspace_windows(main_ws)
    local slave_wins = M.get_workspace_windows(sec_ws)

    local is_on_main = (active_win.workspace and active_win.workspace.id == main_ws.id)

    if is_on_main then
        -- Active window is on main monitor (Master)
        if #slave_wins > 0 then
            local next_slave = slave_wins[1]

            -- 1. Move master to secondary monitor workspace silently
            hl.dispatch(hl.dsp.window.move({
                workspace = sec_ws.id,
                silent = true,
                window = active_win,
            }))

            -- 2. Move slave to main monitor workspace and focus it
            hl.dispatch(hl.dsp.window.move({
                workspace = main_ws.id,
                silent = false,
                window = next_slave,
            }))
            hl.dispatch(hl.dsp.focus({ window = next_slave }))

            hl.notification.create({
                text = "Shuffled: " .. (next_slave.title or "window") .. " is now Master",
                timeout = 1500,
            })
        else
            hl.notification.create({
                text = "No slave windows on secondary monitor to swap with",
                timeout = 1500,
            })
        end
    else
        -- Active window is on secondary monitor (Slave)
        if #master_wins > 0 then
            local old_master = master_wins[1]

            -- 1. Move old master to secondary monitor workspace silently
            hl.dispatch(hl.dsp.window.move({
                workspace = sec_ws.id,
                silent = true,
                window = old_master,
            }))

            -- 2. Move active slave to main monitor workspace and focus it
            hl.dispatch(hl.dsp.window.move({
                workspace = main_ws.id,
                silent = false,
                window = active_win,
            }))
            hl.dispatch(hl.dsp.focus({ window = active_win }))

            hl.notification.create({
                text = "Promoted: " .. (active_win.title or "window") .. " to Master",
                timeout = 1500,
            })
        else
            -- No master currently on main monitor, move active window there
            hl.dispatch(hl.dsp.window.move({
                workspace = main_ws.id,
                silent = false,
                window = active_win,
            }))
            hl.dispatch(hl.dsp.focus({ window = active_win }))
        end
    end
end

--- Promote the currently active window to Master on the main monitor.
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
        -- Already on main monitor
        return
    end

    local master_wins = M.get_workspace_windows(main_ws)
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

    hl.notification.create({
        text = "Promoted to Master: " .. (active_win.title or "window"),
        timeout = 1500,
    })
end

--- Demote the currently active window to the secondary monitor's slave workspace.
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
    local remaining_masters = M.get_workspace_windows(main_ws)
    if #remaining_masters > 0 then
        hl.dispatch(hl.dsp.focus({ window = remaining_masters[1] }))
    else
        hl.dispatch(hl.dsp.focus({ window = active_win }))
    end

    hl.notification.create({
        text = "Demoted to secondary monitor",
        timeout = 1500,
    })
end

--- Cycle focus through slave windows on the secondary monitor.
--- @param dir integer 1 for next, -1 for previous
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
    local slave_wins = M.get_workspace_windows(sec_ws)
    if #slave_wins == 0 then return end

    local active_win = hl.get_active_window()
    local cur_idx = 1
    for idx, w in ipairs(slave_wins) do
        if active_win and w.address == active_win.address then
            cur_idx = idx
            break
        end
    end

    local next_idx = ((cur_idx - 1 + dir) % #slave_wins) + 1
    local target_win = slave_wins[next_idx]
    hl.dispatch(hl.dsp.focus({ window = target_win }))
end

--- Toggle focus between the main monitor and secondary monitor.
function M.toggle_focus()
    local topo = M.get_topology()
    if topo.count < 2 or not topo.secondary then return end

    local active_win = hl.get_active_window()
    local main_ws = topo.main.active_workspace
    local sec_ws = topo.secondary.active_workspace

    if not active_win or not main_ws or not sec_ws then return end

    if active_win.workspace and active_win.workspace.id == main_ws.id then
        -- Focus secondary monitor
        local slave_wins = M.get_workspace_windows(sec_ws)
        if #slave_wins > 0 then
            hl.dispatch(hl.dsp.focus({ window = slave_wins[1] }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = sec_ws.id }))
        end
    else
        -- Focus main monitor
        local master_wins = M.get_workspace_windows(main_ws)
        if #master_wins > 0 then
            hl.dispatch(hl.dsp.focus({ window = master_wins[1] }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = main_ws.id }))
        end
    end
end

-- ============================================
-- CUSTOM LAYOUT ENGINE (hl.layout.register)
-- ============================================

--- Recalculate callback for the custom layout.
--- @param ctx HL.LayoutContext
local function recalculate(ctx)
    local n = #ctx.targets
    if n == 0 then return end

    local area = ctx.area
    local topo = M.get_topology()

    -- Single-monitor fallback: Master on left (ratio), Slaves on right
    if topo.count < 2 or not topo.secondary then
        if n == 1 then
            ctx.targets[1]:place(area)
            return
        end

        local ratio = M.config.single_monitor_master_ratio or 0.55
        local master_w = math.floor(area.w * ratio)
        local slave_w = area.w - master_w
        local slave_x = area.x + master_w

        -- Master window
        ctx.targets[1]:place({
            x = area.x,
            y = area.y,
            w = master_w,
            h = area.h,
        })

        -- Slave stack
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

    -- Multi-monitor setup:
    local target_mon = M.get_monitor_for_area(area)
    local is_main_monitor = (target_mon and target_mon.name == topo.main.name)

    if is_main_monitor then
        -- MAIN MONITOR: Master window monocle
        -- If multiple windows are on the master workspace, the active/top window takes the screen
        for _, target in ipairs(ctx.targets) do
            target:place({
                x = area.x,
                y = area.y,
                w = area.w,
                h = area.h,
            })
        end
    else
        -- SECONDARY MONITOR: Tiled slave windows
        if n == 1 then
            ctx.targets[1]:place(area)
        elseif n <= 3 then
            -- Vertical stack: 1 column split into n rows
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
            -- 4+ windows: 2-column grid to avoid squished rows
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

--- Layout message handler for `hl.dsp.layout("...")`.
--- @param ctx HL.LayoutContext
--- @param msg string
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

-- ============================================
-- LAYOUT DEFINITION FOR MANAGER
-- ============================================

local layout_definition = {
    name = "dual_master",
    display_name = "Dual-Monitor Master",
    engine = "lua:dual_master",

    init = function(self)
        -- Register custom layout with Hyprland's layout engine
        hl.layout.register("dual_master", {
            recalculate = recalculate,
            layout_msg = layout_msg,
        })
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
