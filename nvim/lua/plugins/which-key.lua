return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")
        wk.setup({
            delay = 300,
        })
        wk.add({
            { "<leader>f", group = "find" },
            { "<leader>c", group = "copilot" },
            { "<leader>d", group = "diagnostics" },
        })
    end,
}
