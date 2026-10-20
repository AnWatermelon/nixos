-- layouts/init.lua
-- Entry point for layout configuration and manager initialization.

local manager = require("layouts/manager")
local dual_master = require("layouts/dual_master")
local dwindle = require("layouts/dwindle")
local master = require("layouts/master")

-- Register layouts
manager.register(dual_master.definition)
manager.register(dwindle.definition)
manager.register(master.definition)

-- Set the initial layout (default to dual_master, or change as desired)
manager.set_layout("dual_master", true)

return manager
