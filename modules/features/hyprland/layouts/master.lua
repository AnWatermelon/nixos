local M = {}

M.definition = {
    name = "master",
    display_name = "Master (Standard)",
    engine = "master",

    init = function(self)
        hl.config({
            master = {
                new_status = "master",
            },
        })
    end,

    actions = {
        swap = function()
            hl.dispatch(hl.dsp.layout("swapwithmaster"))
        end,
        promote = function()
            hl.dispatch(hl.dsp.layout("focusmaster"))
        end,
        cycle_next = function()
            hl.dispatch(hl.dsp.layout("cyclenext"))
        end,
        cycle_prev = function()
            hl.dispatch(hl.dsp.layout("cycleprev"))
        end,
    },
}

return M
