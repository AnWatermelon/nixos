-- windowrules.lua

--------------------------
-- APPLICATION BLUR/OPACITY
--------------------------

-- Multimedia video: no blur, full opacity
hl.window_rule({ match = { tag = "multimedia_video*" }, no_blur = true })
hl.window_rule({ match = { tag = "multimedia_video*" }, opacity = "1.0" })

-- Settings panel: slight transparency
hl.window_rule({ match = { tag = "settings*" }, opacity = "0.8" })

-- Kitty terminal
hl.window_rule({ match = { class = "kitty" }, opacity = "0.9" })

-- No opacity changes for browsers
hl.window_rule({ match = { tag = "browser" }, opacity = "1.0 override"})

--------------------------
-- LAYER RULES
--------------------------

-- Notification tag (generic)
hl.layer_rule({ match = { namespace = "notif*" }, ignore_alpha = 0.5 })

hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel)$",
	},
	blur = false,
})

--------------------------
-- FLOATING RULES
--------------------------

-- Tag-based floats
hl.window_rule({ match = { tag = "settings*" }, float = true })
hl.window_rule({ match = { tag = "viewer*" }, float = true })
hl.window_rule({ match = { tag = "multimedia_video*" }, float = true, size = { 900, 506 } })
hl.window_rule({
	match = {
		tag = "^(file_chooser)$",
	},
	float = true,
	center = true,
	size = { 1000, 650 },
})

-- Suppress maximize events globally
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix XWayland drag issues
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

--------------------------
-- DIALOGUES / POP-UPS
--------------------------

-- Save / pick-file dialogs
hl.window_rule({
	match = { title = "Save As|Save a File|Pick Files" },
	float = true,
	size = { "50%", "60%" },
	center = true,
})

-- "Open Files" dialog (matched by initialTitle)
hl.window_rule({
	match = { initial_title = "Open Files" },
	float = true,
	size = { "70%", "60%" },
})
