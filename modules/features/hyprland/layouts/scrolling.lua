local M = {}

M.config = {
    resize_step = 0.05,
}

local gesture_overridden = false

local function set_swipe_action(action)
    hl.gesture({ fingers = 3, direction = "horizontal", action = "unset" })
    hl.gesture({ fingers = 3, direction = "horizontal", action = action })
end

M.definition = {
    name = "scrolling",
    display_name = "Scrolling",
    engine = "scrolling",

    init = function(self)
        hl.config({
            scrolling = {
                column_width = 0.5,
                fullscreen_on_one_column = true,
                explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
            },
        })
    end,

    on_activate = function(self)
        if gesture_overridden then return end
        set_swipe_action("scroll_move")
        gesture_overridden = true
    end,

    on_deactivate = function(self)
        if not gesture_overridden then return end
        set_swipe_action("workspace")
        gesture_overridden = false
    end,

    actions = {
        toggle_full_width = function()
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
        end,
        grow_width = function()
            hl.dispatch(hl.dsp.layout("colresize +" .. M.config.resize_step))
        end,
        shrink_width = function()
            hl.dispatch(hl.dsp.layout("colresize -" .. M.config.resize_step))
        end,
        cycle_width = function()
            hl.dispatch(hl.dsp.layout("colresize +conf"))
        end,
        scroll_next = function()
            hl.dispatch(hl.dsp.layout("focus r"))
        end,
        scroll_prev = function()
            hl.dispatch(hl.dsp.layout("focus l"))
        end,
        cycle_next = function()
            hl.dispatch(hl.dsp.layout("focus r"))
        end,
        cycle_prev = function()
            hl.dispatch(hl.dsp.layout("focus l"))
        end,
        promote = function()
            hl.dispatch(hl.dsp.layout("promote"))
        end,
        toggle_split = function()
            hl.dispatch(hl.dsp.layout("consume_or_expel next"))
        end,
    },
}

return M
