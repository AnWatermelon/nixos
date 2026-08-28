-- hyprland.lua
-- ============================================
-- MONITORS
-- ============================================
-- An empty output matches every monitor.
hl.monitor({
	output = "",
	mode = "highres",
	position = "auto",
	scale = "auto",
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
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_USE_PORTAL", "1")

local nvidia_loaded = io.open("/sys/module/nvidia", "r") ~= nil
if nvidia_loaded then
	hl.env("GBM_BACKEND", "nvidia-drm")
	hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
end

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
require("configs/gpu")
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

-- For Noctalia Color templates. noctalia.lua is rendered at runtime by the
-- noctalia daemon, so it is absent on a fresh machine — guard the require or
-- the whole config fails to load before noctalia has ever run.
local ok, noctalia = pcall(require, "noctalia")
if ok then
	noctalia.apply_theme()
end
