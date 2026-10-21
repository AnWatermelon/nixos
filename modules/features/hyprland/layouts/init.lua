local manager = require("layouts/manager")
local dual_master = require("layouts/dual_master")
local dwindle = require("layouts/dwindle")
local master = require("layouts/master")

dual_master.load_display_config()

manager.register(dual_master.definition)
manager.register(dwindle.definition)
manager.register(master.definition)

if manager.is_layout_available("dual_master") then
    manager.set_layout("dual_master", true)
else
    manager.set_layout("dwindle", true)
end

pcall(function()
    hl.on("hyprland.start", function()
        if manager.current_name == "dwindle" and manager.is_layout_available("dual_master") then
            manager.set_layout("dual_master", true)
        end
    end)
end)

return manager
