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
    table.insert(M.layout_order, def.name)
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

    local next_idx = ((current_idx - 1 + step) % #M.layout_order) + 1
    M.set_layout(M.layout_order[next_idx])
end

function M.dispatch_action(action_name, ...)
    local layout = M.get_active_layout()
    if layout and layout.actions and layout.actions[action_name] then
        return layout.actions[action_name](...)
    end
end

return M
