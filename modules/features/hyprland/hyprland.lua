-- hyprland.lua
-- ============================================
-- MONITORS
-- ============================================
hl.monitor({
	output = "DP-1",
	mode = "2560x144@165",
	position = "-2560x0",
})

hl.monitor({
	output = "DP-3",
	mode = "2560x1440@165",
	position = "0x0",
})

-- ============================================
-- AUTOSTART
-- ============================================
hl.on("hyprland.start", function()
	hl.exec_cmd("noctalia")
end)

-- ============================================
-- ENVIRONMENT VARIABLES
-- ============================================
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_USE_PORTAL", "1")
hl.env("GDK_DEBUG", "portals")
-- ============================================
-- TAGS (modular file)
-- ============================================
require("configs/tags")

-- ============================================
-- LOOK AND FEEL (modular file)
-- ============================================
require("configs/looknfeel")

-- ============================================
-- ANIMATIONS (modular file)
-- ============================================
require("configs/UserAnimations")

-- ============================================
-- SMART GAPS (commented out by default)
-- ============================================
-- hl.workspace_rule({
--     workspace = "w[tv1]",
--     gaps_out = 0,
--     gaps_in  = 0,
-- })
-- hl.workspace_rule({
--     workspace = "f[1]",
--     gaps_out = 0,
--     gaps_in  = 0,
-- })
-- hl.window_rule({
--     match       = { float = 0, workspace = "w[tv1]" },
--     border_size = 0,
-- })
-- hl.window_rule({
--     match    = { float = 0, workspace = "w[tv1]" },
--     rounding = 0,
-- })
-- hl.window_rule({
--     match       = { float = 0, workspace = "f[1]" },
--     border_size = 0,
-- })
-- hl.window_rule({
--     match    = { float = 0, workspace = "f[1]" },
--     rounding = 0,
-- })

-- ============================================
-- WINDOW RULES & LAYER RULES (modular file)
-- ============================================
require("configs/windowrules")

-- ============================================
-- LAYOUTS
-- ============================================

-- Dwindle layout settings
hl.config({
	dwindle = {
		preserve_split = true, -- you probably want this
	},
})

-- Master layout settings
hl.config({
	master = {
		new_status = "master",
	},
})

-- ============================================
-- MISC
-- ============================================
hl.config({
	misc = {
		force_default_wallpaper = 0, -- disable anime mascot wallpapers
		disable_hyprland_logo = true, -- disable random hyprland logo / anime girl background
	},
})

-- ============================================
-- RENDER
-- ============================================
hl.config({
	render = {
		new_render_scheduling = true,
	},
})

-- ============================================
-- INPUT (modular file)
-- ============================================
require("configs/input")

-- ============================================
-- KEYBINDS (modular file)
-- ============================================
require("configs/keybinds")

-- For Noctalia Color templates
require("noctalia").apply_theme()
