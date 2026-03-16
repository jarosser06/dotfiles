return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            [[                                                       ]],
            [[                         /\                             ]],
            [[                        /  \          /\                ]],
            [[               /\      /    \        /  \               ]],
            [[              /  \    /      \    /\/    \              ]],
            [[             /    \  /   /\   \  /       /\             ]],
            [[         /\ /      \/   /  \   \/       /  \            ]],
            [[        /  \           /    \           /    \           ]],
            [[       /    \        /        \        /      \          ]],
            [[   ~~~/      \~~~~~~/    /\    \~~~~~~/        \~~~~    ]],
            [[   ~~~~~~~~~~/     /    /  \    \    /     ~~~~~~~~~~   ]],
            [[    ~ ~~~  ~/ ^^  /  ^ /    \ ^  \ / ^^  ~ ~~~  ~~    ]],
            [[                                                       ]],
            [[              ]].. " " ..[[      ]].. " " ..[[      ]].. " " ..[[                    ]],
            [[                                                       ]],
        }

        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
            dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
            dashboard.button("g", "  Grep text", "<cmd>Telescope live_grep<CR>"),
            dashboard.button("e", "  New file", "<cmd>ene<CR>"),
            dashboard.button("c", "  Config", "<cmd>e ~/.config/nvim/init.lua<CR>"),
            dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
        }

        dashboard.section.footer.val = "  happy trails  "

        dashboard.section.header.opts.hl = "GruvboxGreen"
        dashboard.section.buttons.opts.hl = "GruvboxOrange"
        dashboard.section.footer.opts.hl = "GruvboxAqua"

        alpha.setup(dashboard.opts)
    end,
}
