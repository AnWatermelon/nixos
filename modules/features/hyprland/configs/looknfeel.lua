-- looknfeel.lua

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,

		border_size = 2,

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
		allow_tearing = false,

		layout = "dwindle",
	},

	-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
	decoration = {
		rounding = 20,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 0.8,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		-- https://wiki.hypr.land/Configuring/Basics/Variables/#blur
		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			ignore_opacity = true,
			new_optimizations = true,
			special = false,
			popups = true,
			xray = true,
			vibrancy = 0.1696,
		},
	},
})

if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass

	hg.config({
		default_theme = "dark",
		default_preset = "apple",
		tint_color = 0x8899aa22,

		brightness = 0.9,
		dark = { brightness = 0.82 },
		light = { adaptive_boost = 0.5 },

		layers = { enabled = 1 },
	})

	-- Layer surfaces: each call whitelists the namespace and configures it
	hg.layer("waybar", { preset = "subtle", mask_threshold = 0.05 })
	hg.layer("swaync")
	hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
	hg.layer("debug-panel", { exclude = true })
	hg.layer("noctalia", { preset = "apple" })
	-- Presets
	hg.preset("clear", {
		glass_opacity = 0.5,
		blur_strength = 2.0,
		dark = { brightness = 0.7 },
		light = { brightness = 1.2 },
	})

	hg.preset("glass", {
		glass_opacity = 0.7,
		blur_strength = 2.0,
		blur_iterations = 3,
		chromatic_aberration = 0.4,
		fresnel_strength = 1.0,
		edge_thickness = 0.18,
		lens_distortion = 0.2,
		-- brightness = 1.0,
		-- contrast = 1.7,
		-- saturation = 1,
		-- vibrancy = 0.8,
		vibrancy_darkness = 1,
		-- adaptive_boost = 0.5,
		dark = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
		light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
	})

	hg.preset("apple", {
		glass_opacity = 0.6,
		blur_strength = 2.2,
		blur_iterations = 3,
		refraction_strength = 0.70,
		chromatic_aberration = 0.3,
		specular_strength = 0.75,
		edge_thickness = 0.4,
		fresnel_strength = 0.6,
		lens_distortion = 0.7,
		dark = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
		light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
	})
end
