local M = {}

M.definition = {
    name = "dwindle",
    display_name = "Dwindle",
    engine = "dwindle",

    init = function(self)
        hl.config({
            dwindle = {
                preserve_split = true,
            },
        })
    end,

    actions = {
        toggle_split = function()
            hl.dispatch(hl.dsp.layout("togglesplit"))
        end,
        cycle_next = function()
            hl.dispatch(hl.dsp.focus({ direction = "r" }))
        end,
        cycle_prev = function()
            hl.dispatch(hl.dsp.focus({ direction = "l" }))
        end,
    },
}

return M
