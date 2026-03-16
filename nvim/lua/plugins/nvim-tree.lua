return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
    },
    config = function()
        require("nvim-tree").setup({
            view = { width = 35 },
            filters = { dotfiles = false },
            git = { enable = true },
        })
    end,
}
