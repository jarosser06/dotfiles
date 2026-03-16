return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local colors = {
            orange = "#d65d0e",
            yellow = "#d79921",
            aqua   = "#689d6a",
            fg     = "#fbf1c7",
            bg     = "#3c3836",
            blue   = "#458588",
        }

        local pnw_theme = {
            normal = {
                a = { bg = colors.orange, fg = colors.fg, gui = "bold" },
                b = { bg = colors.yellow, fg = colors.bg },
                c = { bg = colors.bg, fg = colors.fg },
                z = { bg = colors.aqua, fg = colors.fg, gui = "bold" },
            },
            insert = {
                a = { bg = colors.aqua, fg = colors.fg, gui = "bold" },
                z = { bg = colors.orange, fg = colors.fg, gui = "bold" },
            },
            visual = {
                a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
                z = { bg = colors.orange, fg = colors.fg, gui = "bold" },
            },
            command = {
                a = { bg = colors.blue, fg = colors.fg, gui = "bold" },
                z = { bg = colors.orange, fg = colors.fg, gui = "bold" },
            },
        }

        require("lualine").setup({
            options = {
                theme = pnw_theme,
                section_separators = { left = "", right = "" },
                component_separators = { left = "|", right = "|" },
            },
            sections = {
                lualine_a = { function() return " " end },
                lualine_b = { "branch", "diff" },
                lualine_c = { "filename", "diagnostics" },
                lualine_x = { "filetype" },
                lualine_y = { "progress", "location" },
                lualine_z = { function() return " " end },
            },
        })
    end,
}
