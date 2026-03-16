return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = {
                "pyright",
                "rust_analyzer",
                "gopls",
                "ts_ls",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        config = function()
            local servers = { "pyright", "rust_analyzer", "gopls", "ts_ls" }
            for _, server in ipairs(servers) do
                vim.lsp.config(server, {})
            end
            vim.lsp.enable(servers)

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
                    end
                    map("gd", vim.lsp.buf.definition, "Go to definition")
                    map("gr", vim.lsp.buf.references, "Go to references")
                    map("K", vim.lsp.buf.hover, "Hover docs")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
                    map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
                    map("]d", vim.diagnostic.goto_next, "Next diagnostic")
                end,
            })
        end,
    },
}
