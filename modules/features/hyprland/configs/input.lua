-- input.lua

hl.config({
  input = {
    kb_layout      = "us",
    kb_variant     = "",
    kb_model       = "",
    kb_options     = "",
    kb_rules       = "",

    follow_mouse   = 1,
    sensitivity    = 0,    -- -1.0 to 1.0, 0 means no modification
    accel_profile  = "flat",
    force_no_accel = true,
  },

  -- https://wiki.hypr.land/Configuring/Basics/Variables/#gestures
  gestures = {

  },
})

-- Per-device config
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})
