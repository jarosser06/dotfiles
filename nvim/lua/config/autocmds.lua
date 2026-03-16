local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- highlight on yank
autocmd("TextYankPost", {
    group = augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
})

-- 2-space indent for web languages
autocmd("FileType", {
    group = augroup("WebIndent", { clear = true }),
    pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "yaml", "html", "css" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- auto-resize splits on window resize
autocmd("VimResized", {
    group = augroup("ResizeSplits", { clear = true }),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- remove trailing whitespace on save
autocmd("BufWritePre", {
    group = augroup("TrimWhitespace", { clear = true }),
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})
