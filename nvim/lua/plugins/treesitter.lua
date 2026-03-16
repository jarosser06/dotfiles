return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = {
                "python", "rust", "go", "typescript", "tsx", "javascript",
                "lua", "json", "yaml", "toml", "html", "css", "bash", "markdown",
            },
        })
    end,
}
