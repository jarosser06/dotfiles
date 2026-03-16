return {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    cmd = { "CopilotChat", "CopilotChatExplain", "CopilotChatFix", "CopilotChatReview" },
    keys = {
        { "<leader>cc", "<cmd>CopilotChat<CR>", mode = { "n", "v" }, desc = "Copilot Chat" },
        { "<leader>ce", "<cmd>CopilotChatExplain<CR>", mode = "v", desc = "Copilot Explain" },
        { "<leader>cf", "<cmd>CopilotChatFix<CR>", mode = "v", desc = "Copilot Fix" },
        { "<leader>cr", "<cmd>CopilotChatReview<CR>", mode = "v", desc = "Copilot Review" },
    },
    config = function()
        require("CopilotChat").setup({
            window = {
                layout = "vertical",
                width = 0.4,
            },
        })
    end,
}
