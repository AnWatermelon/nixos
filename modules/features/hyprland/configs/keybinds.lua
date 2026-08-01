-- keybinds.lua

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "kitty --hold -e zsh -i -c 'y'"
local ipc = "noctalia msg"
local browser = "zen-browser"
local scripts = "sh ~/.config/scripts/"

-- ─────────────────────────────────────────────
--  Basic application launchers
-- ─────────────────────────────────────────────
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. " panel-toggle session"))
hl.bind(mainMod .. " + E", hl.dsp.exec_raw(fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Super_L", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(ipc .. " config-reload"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(ipc .. " session lock"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(ipc .. " screenshot-region"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(ipc .. " panel-toggle wallpaper"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_raw("sh ~/.config/hypr/scripts/KillActiveProcess.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. " panel-open clipboard"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(ipc .. " settings-toggle"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(ipc .. " panel-open maxfh/noctagent:chat"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_raw(scripts .. "toggle_audio.sh"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center system"))
-- ─────────────────────────────────────────────
--  Focus movement (arrow keys)
-- ─────────────────────────────────────────────
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

-- ─────────────────────────────────────────────
--  Window movement (SHIFT + arrow keys)
-- ─────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- ─────────────────────────────────────────────
--  Window resize (CTRL + arrow keys, repeating)
-- ─────────────────────────────────────────────
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

-- ─────────────────────────────────────────────
--  Workspace switching (mainMod + 1-0)
-- ─────────────────────────────────────────────
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- ─────────────────────────────────────────────
--  Move window to workspace (mainMod + SHIFT + 1-0)
-- ─────────────────────────────────────────────
for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + ALT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mainMod .. " + SHIFT + ALT + 0 + ", hl.dsp.window.move({ workspace = 10, follow = false }))
-- ─────────────────────────────────────────────
--  Special workspace (scratchpad) — uncomment to enable
-- ─────────────────────────────────────────────
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- ─────────────────────────────────────────────
--  Scroll through workspaces with mouse wheel
-- ─────────────────────────────────────────────
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ─────────────────────────────────────────────
--  Move / resize windows with mouse drag
-- ─────────────────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ─────────────────────────────────────────────
--  Multimedia / brightness keys (locked + repeating)
-- ─────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"))

-- Media player control (playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
