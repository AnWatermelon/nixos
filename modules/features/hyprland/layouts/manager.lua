-- layouts/manager.lua
-- Layout management infrastructure for Hyprland.
-- Allows organizing layouts cleanly and switching dynamically via keybinds.

local M = {}

M.layouts = {}
M.layout_order = {}
M.current_name = nil

--- Register a layout definition with the manager.
--- @param def table Layout definition containing:
---   name: string (unique identifier, e.g. "dual_master")
---   display_name: string (human-readable title, e.g. "Dual-Monitor Master")
---   engine: string (Hyprland general.layout string, e.g. "lua:dual_master" or "dwindle")
---   init: function|nil (optional one-time setup)
---   on_activate: function|nil (callback when switched to)
---   on_deactivate: function|nil (callback when switched away from)
---   actions: table<string, function> (layout-specific actions: swap, promote, demote, cycle_next, etc.)
function M.register(def)
    assert(def.name, "Layout definition must have a 'name'")
    assert(def.engine, "Layout definition must have an 'engine'")
    def.display_name = def.display_name or def.name
    def.actions = def.actions or {}

    if def.init then
        def.init(def)
    end

    M.layouts[def.name] = def
    table.insert(M.layout_order, def.name)
end

--- Get the currently active layout definition.
--- @return table|nil
function M.get_active_layout()
    if not M.current_name then return nil end
    return M.layouts[M.current_name]
end

--- Switch to a layout by name.
--- @param name string
--- @param silent boolean|nil
function M.set_layout(name, silent)
    local layout = M.layouts[name]
    if not layout then
        local err_msg = "Unknown layout: " .. tostring(name)
        hl.notification.create({ text = err_msg, timeout = 3000 })
        return false
    end

    if M.current_name and M.current_name ~= name then
        local old_layout = M.layouts[M.current_name]
        if old_layout and old_layout.on_deactivate then
            pcall(old_layout.on_deactivate, old_layout)
        end
    end

    M.current_name = name

    -- Configure Hyprland's active layout engine
    hl.config({
        general = {
            layout = layout.engine,
        },
    })

    if layout.on_activate then
        pcall(layout.on_activate, layout)
    end

    if not silent then
        hl.notification.create({
            text = "Layout: " .. layout.display_name,
            timeout = 2000,
        })
    end

    return true
end

--- Cycle to the next or previous layout in the registered order.
--- @param step integer|nil Step direction (default: 1)
function M.cycle_layout(step)
    step = step or 1
    if #M.layout_order == 0 then return end

    local current_idx = 1
    for idx, name in ipairs(M.layout_order) do
        if name == M.current_name then
            current_idx = idx
            break
        end
    end

    local next_idx = ((current_idx - 1 + step) % #M.layout_order) + 1
    local next_name = M.layout_order[next_idx]
    M.set_layout(next_name)
end

--- Dispatch a layout-specific action to the active layout.
--- @param action_name string
--- @param ... any
function M.dispatch_action(action_name, ...)
    local layout = M.get_active_layout()
    if layout and layout.actions and layout.actions[action_name] then
        return layout.actions[action_name](...)
    end
end

return M
