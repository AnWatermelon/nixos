local manager = require("layouts/manager")
local dual_master = require("layouts/dual_master")
local dwindle = require("layouts/dwindle")
local master = require("layouts/master")

manager.register(dual_master.definition)
manager.register(dwindle.definition)
manager.register(master.definition)

manager.set_layout("dual_master", true)

return manager
