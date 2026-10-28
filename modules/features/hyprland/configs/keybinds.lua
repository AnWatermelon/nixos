local manager = require("layouts/manager")

local mainMod = "SUPER"
local apps = require("nix/apps")
local fileManager = "nemo"
local ipc = "noctalia msg"

hl.bind(mainMod .. " + Backspace", function()
	manager.cycle_layout(1)
end)

hl.bind(mainMod .. " + CTRL + Backspace", function()
	manager.cycle_layout(-1)
end)

hl.bind(mainMod .. " + ALT + 1", function()
	manager.set_layout("dual_master")
end)

hl.bind(mainMod .. " + ALT + 2", function()
	manager.set_layout("dwindle")
end)

hl.bind(mainMod .. " + ALT + 3", function()
	manager.set_layout("master")
end)

hl.bind(mainMod .. " + Return", function()
	manager.dispatch_action("swap")
end)

hl.bind(mainMod .. " + SHIFT + Return", function()
	manager.dispatch_action("promote")
end)

hl.bind(mainMod .. " + M", function()
	manager.dispatch_action("swap")
end)

hl.bind(mainMod .. " + SHIFT + M", function()
	manager.dispatch_action("demote")
end)

hl.bind(mainMod .. " + Tab", function()
	manager.dispatch_action("cycle_next")
end)

hl.bind(mainMod .. " + SHIFT + Tab", function()
	manager.dispatch_action("cycle_prev")
end)

hl.bind(mainMod .. " + O", function()
	manager.dispatch_action("toggle_focus")
end)

hl.bind(mainMod .. " + backslash", function()
	manager.dispatch_action("toggle_split")
end)

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(apps.terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. " panel-toggle session"))
hl.bind(mainMod .. " + E", hl.dsp.exec_raw(fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Super_L", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"), { release = true })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(ipc .. " config-reload"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(apps.browser))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(ipc .. " screenshot-region"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(ipc .. " panel-toggle wallpaper"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. " panel-open clipboard"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(ipc .. " settings-toggle"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(ipc .. " panel-open maxfh/noctagent:chat"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_raw("toggle_audio"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center system"))
hl.bind("ALT + TAB", hl.dsp.exec_cmd(ipc .. " window-switcher"))

local SPAN_W, SPAN_H = 5120, 1440
local NORMAL_W, NORMAL_H = 2560, 1440
local spanned = {}

hl.bind(mainMod .. " + CTRL + S", function()
	local w = hl.get_active_window()
	if w == nil then return end

	if spanned[w.address] then
		hl.dispatch(hl.dsp.window.set_prop({ prop = "border_size", value = hl.get_config("general.border_size"), window = w }))
		hl.dispatch(hl.dsp.window.set_prop({ prop = "rounding", value = hl.get_config("decoration.rounding"), window = w }))
		hl.dispatch(hl.dsp.window.float({ action = "unset", window = w }))
		hl.dispatch(hl.dsp.window.resize({ x = NORMAL_W, y = NORMAL_H, window = w }))
		hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-show"))
		spanned[w.address] = nil
	else
		hl.dispatch(hl.dsp.window.set_prop({ prop = "border_size", value = 0, window = w }))
		hl.dispatch(hl.dsp.window.set_prop({ prop = "rounding", value = 0, window = w }))
		hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
		hl.dispatch(hl.dsp.window.resize({ x = SPAN_W, y = SPAN_H, window = w }))
		hl.dispatch(hl.dsp.window.move({ x = 0, y = 0, window = w }))
		hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-hide"))
		spanned[w.address] = true
	end
end)

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + ALT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mainMod .. " + SHIFT + ALT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. " media next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. " media toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. " media toggle"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc.. " media previous"), { locked = true })
