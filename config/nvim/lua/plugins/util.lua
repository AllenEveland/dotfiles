return {
    {
        "folke/snacks.nvim",
        lazy = false,
        opts = {
            input = { enabled = true },
        },
    },

    {
        "yetone/avante.nvim",
        build = "make",
        lazy = false,
        version = false,
        cond = function()
            local APIKEY = "OPENAI_API_KEY"
            local key = os.getenv(APIKEY)
            if not key or key == "" then
                vim.schedule(function()
                    vim.notify("Avante disabled: " .. APIKEY .. " not found", vim.log.levels.WARN)
                end)
                return false
            end
            return true
        end,

        dependencies = {
            "folke/snacks.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        opts = {
            provider = "openai",
            providers = {
                -- OpenAI
                openai = {
                    endpoint = "https://api.openai.com/v1",
                    model = "gpt-4o-mini",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_tokens = 8182,
                    },
                },

                -- Claude
                claude = {
                    endpoint = "https://api.anthropic.com/v1/messages",
                    model = "claude-3-5-sonnet-20241022",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_tokens = 8192,
                    },
                },
            },

            behaviour = {
                auto_suggestions = false,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = true,
            },
        },
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "│" },
                change       = { text = "│" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~" },
                untracked    = { text = "┆" },
            },

            signcolumn = true,

            preview_config = {
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
        },

        config = function(_, opts)
            local gitsigns = require("gitsigns")
            gitsigns.setup(opts)

            local map = vim.keymap.set
            local function desc(t) return { desc = "Git: " .. t } end

            map("n", "<leader>gn", function()
                gitsigns.next_hunk()
                gitsigns.preview_hunk_inline()
            end, desc("Next hunk inline preview"))

            map("n", "<leader>gp", function()
                gitsigns.prev_hunk()
                gitsigns.preview_hunk_inline()
            end, desc("Previous hunk inline preview"))

            map("n", "<C-g>", gitsigns.preview_hunk_inline, desc("Preview hunk inline"))
        end,
    },

    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("Comment").setup()

            vim.keymap.set("n", "<leader>/", function()
                require("Comment.api").toggle.linewise.current()
            end)

            vim.keymap.set("v", "<leader>/", function()
                local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
                vim.api.nvim_feedkeys(esc, "nx", false)
                require("Comment.api").toggle.linewise(vim.fn.visualmode())
            end)
        end,
    },

    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        lazy = false,
        opts = {
            formatters_by_ft = {
                python = { "black" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                rust = { "rustfmt" },
            },
        },
        config = function(_, opts)
            local conform = require("conform")
            conform.setup(opts)

            vim.keymap.set("n", "<S-f>", function()
                conform.format({
                    async = true,
                    lsp_fallback = true,
                })
            end, { desc = "Format code" })
        end,
    },

    {
        "folke/which-key.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")

            wk.setup({
                plugins = {
                    spelling = { enabled = true, suggestions = 20 },
                },
                triggers = { "<leader>" },
                show_help = false,
                win = {
                    border = "rounded",
                },
            })
        end,
    },

    {
        "folke/todo-comments.nvim",
        event = "BufReadPost",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "TodoTrouble", "TodoTelescope" },

        opts = {
            signs = true,
            sign_priority = 8,

            keywords = {
                FIX = {
                    icon = " ",
                    color = "error",
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
                },
                TODO = {
                    icon = " ",
                    color = "info",
                },
                HACK = {
                    icon = " ",
                    color = "warning",
                },
                WARN = {
                    icon = " ",
                    color = "warning",
                    alt = { "WARNING", "XXX" },
                },
                PERF = {
                    icon = " ",
                    alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
                },
                NOTE = {
                    icon = " ",
                    color = "hint",
                    alt = { "INFO" },
                },
                TEST = {
                    icon = "⏲ ",
                    color = "test",
                    alt = { "TESTING", "PASSED", "FAILED" },
                },
            },

            gui_style = {
                fg = "NONE",
                bg = "BOLD",
            },

            merge_keywords = true,

            highlight = {
                multiline = true,
                multiline_pattern = "^.",
                multiline_context = 10,

                before = "",
                keyword = "wide",
                after = "fg",

                pattern = [[.*<(KEYWORDS)\s*:]],
                comments_only = true,
                max_line_len = 400,
                exclude = {},
            },

            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "Identifier", "#FF00FF" },
            },

            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },
                pattern = [[\b(KEYWORDS):]],
            },
        },
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },

        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            local list = harpoon:list()

            vim.keymap.set("n", "<A-a>", function()
                list:add()
                vim.notify("Added " .. vim.fn.expand("%") .. " to marks", vim.log.levels.INFO)
            end, { desc = "Harpoon Add" })

            vim.keymap.set("n", "<A-h>", function()
                harpoon.ui:toggle_quick_menu(list)
            end, { desc = "Harpoon Menu" })

            for i = 1, 9 do
                vim.keymap.set("n", "<A-" .. i .. ">", function()
                    list:select(i)
                end, { desc = "Harpoon Select " .. i })
            end

            vim.keymap.set("n", "<A-n>", function()
                list:next()
            end, { desc = "Harpoon Next" })

            vim.keymap.set("n", "<A-p>", function()
                list:prev()
            end, { desc = "Harpoon Prev" })

            vim.keymap.set("n", "<A-x>", function()
                list:remove()
                vim.notify("Removed " .. vim.fn.expand("%") .. " from marks", vim.log.levels.INFO)
            end, { desc = "Harpoon Remove" })
        end,
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",

        config = function()
            require("nvim-surround").setup({})
        end,
    },

    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },

        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- =========================
            -- BANNER
            -- =========================
            dashboard.section.header.val = {
                "",
                "",
                "",
                "",
                "",
                "",
                "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                " ",
            }

            -- =========================
            -- MENU
            -- =========================
            dashboard.section.buttons.val = {
                dashboard.button("SPC f e", "󰙅  File explorer"),
                dashboard.button("SPC f f", "󰱼  Find file"),
                dashboard.button("SPC f a", "󰈞  Find all thing"),
                dashboard.button("SPC f k", "󰌌  Keymap list"),
                dashboard.button("SPC t f", "  Floating terminal"),
                dashboard.button("SPC t d", "  Down terminal"),
                dashboard.button("SPC a a", "󰚩  Avante AI Chat"),
            }

            dashboard.section.header.opts.hl = "Type"
            dashboard.section.buttons.opts.hl = "Keyword"

            -- disable auto folding
            vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
            alpha.setup(dashboard.opts)
        end,
    }
}
