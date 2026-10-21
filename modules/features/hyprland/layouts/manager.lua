local M = {}

M.layouts = {}
M.layout_order = {}
M.current_name = nil

function M.register(def)
    assert(def.name and def.engine, "Layout must define name and engine")
    def.display_name = def.display_name or def.name
    def.actions = def.actions or {}

    if def.init then
        def.init(def)
    end

    M.layouts[def.name] = def
    local found = false
    for _, name in ipairs(M.layout_order) do
        if name == def.name then
            found = true
            break
        end
    end
    if not found then
        table.insert(M.layout_order, def.name)
    end
end

function M.is_layout_available(name)
    local layout = M.layouts[name]
    if not layout then return false end
    if layout.is_available then
        local ok, avail = pcall(layout.is_available, layout)
        if ok then return avail end
        return false
    end
    if layout.is_enabled then
        local ok, enabled = pcall(layout.is_enabled, layout)
        if ok then return enabled end
        return false
    end
    return true
end

function M.get_active_layout()
    if not M.current_name then return nil end
    return M.layouts[M.current_name]
end

function M.set_layout(name, silent)
    local layout = M.layouts[name]
    if not layout then
        hl.notification.create({ text = "Unknown layout: " .. tostring(name), timeout = 3000 })
        return false
    end

    if not M.is_layout_available(name) then
        if not silent then
            local reason = layout.unavailable_reason or layout.disabled_reason or (layout.display_name .. " is not available")
            hl.notification.create({ text = reason, timeout = 3000 })
        end
        return false
    end

    if M.current_name and M.current_name ~= name then
        local old_layout = M.layouts[M.current_name]
        if old_layout and old_layout.on_deactivate then
            pcall(old_layout.on_deactivate, old_layout)
        end
    end

    M.current_name = name

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

    local n = #M.layout_order
    for offset = 1, n do
        local candidate_idx = ((current_idx - 1 + (step * offset)) % n) + 1
        local candidate_name = M.layout_order[candidate_idx]
        if M.is_layout_available(candidate_name) then
            M.set_layout(candidate_name)
            return
        end
    end
end

function M.dispatch_action(action_name, ...)
    local layout = M.get_active_layout()
    if layout and layout.actions and layout.actions[action_name] then
        return layout.actions[action_name](...)
    end
end

local function handle_monitor_change()
    if M.current_name and not M.is_layout_available(M.current_name) then
        local old_layout = M.layouts[M.current_name]
        local name = old_layout and old_layout.display_name or M.current_name
        hl.notification.create({
            text = name .. " disabled (requires 2 monitors). Switching to Dwindle.",
            timeout = 3000,
        })
        if not M.set_layout("dwindle") then
            M.cycle_layout(1)
        end
    end
end

pcall(function()
    hl.on("monitor.added", handle_monitor_change)
    hl.on("monitor.removed", handle_monitor_change)
end)

return M
