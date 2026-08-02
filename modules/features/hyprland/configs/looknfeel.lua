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
