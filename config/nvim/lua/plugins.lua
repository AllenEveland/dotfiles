return {
	-- [[ UI ]]
	{
        "navarasu/onedark.nvim",
        priority = 1000,
        config = function()
            require("onedark").setup({
                style          = "warmer",
                transparent    = false,
                term_colors    = true,
                ending_tildes  = false,
                code_style = {
                    comments  = "italic",
                    keywords  = "none",
                    functions = "none",
                    strings   = "none",
                    variables = "none",
                },
                toggle_style_key  = "<leader>ts",
                toggle_style_list = { "dark", "warm", "warmer", "cool", "deep", "darker" },
                diagnostics = {
                    darker     = true,
                    undercurl  = true,
                    background = true,
                },
            })
            require("onedark").load()
        end,
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = false,            
                    mode = "buffers",
                    show_buffer_close_icons = true,
                    show_close_icon = true,
                    separator_style = "slant",
                }
            })
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        config = function()
            require("lualine").setup({
                options = {
                    theme = "onedark",
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                    globalstatus = true,
                    icons_enabled = true,
                },
                sections = {
                    lualine_a = { { "mode" } },
                    lualine_b = {
                        "branch",
                        { "diff", symbols = { added = " ", modified = " ", removed = " " } },
                        { "filename", file_status = true, path = 1, gui = "bold" },
                    },
                    lualine_c = { "%=" },
                    lualine_x = {},
                    lualine_y = {
                        { "filetype", icon_only = false },
                        { "encoding" },
                        { "fileformat", icons_enabled = true },
                    },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = { "filename" },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = { "location" },
                },
            })
        end,
    },
    {
        "rcarriga/nvim-notify",
        lazy = false,
        config = function()
            local notify = require("notify")
            notify.setup({
                timeout          = 5000,
                stages           = "fade_in_slide_out",
                background_colour = "#000000",
            })
            vim.notify = notify
        end,
    },

    -- [[ CORE ]]
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            map_cr = true,
            map_bs = true,
            enable_check_bracket_line = true,
            disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
            require("nvim-autopairs").setup(opts)
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("ibl").setup({
                scope = {
                    enabled = true,
                    show_start = false,
                    show_end = false,
                },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        },
        config = function()
            local treesitter = require("nvim-treesitter")

            treesitter.setup({
                indent = { enable = true },
            })

            treesitter.install({
                "python", "c", "cpp", "asm", "llvm", "rust",
                "bash",
                "cmake", "make", "ninja", "dockerfile",
                "awk", "regex",
                "javascript", "typescript", "json",
                "markdown", "markdown_inline",
                "query",
                "yaml", "toml", "ini", "gitignore",
            })

            require("nvim-treesitter-textobjects").setup({
                move = {
                    enable    = true,
                    set_jumps = true,
                },
                swap = { enable = true },
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function(args)
                    local buf           = args.buf
                    local max_lines     = 50000
                    local max_filesize  = 10 * 1024 * 1024

                    local too_large = vim.api.nvim_buf_line_count(buf) > max_lines
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        too_large = true
                    end

                    if not too_large then
                        pcall(vim.treesitter.start, buf)
                        vim.wo[0][0].foldmethod = "expr"
                        vim.wo[0][0].foldexpr   = "v:lua.vim.treesitter.foldexpr()"
                        vim.wo[0][0].foldenable  = false
                    else
                        vim.notify("File too large for treesitter parsing", vim.log.levels.WARN)
                    end
                end,
            })

            vim.keymap.set({ "n", "x", "o" }, "]f", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
            end, { desc = "Next function start" })

            vim.keymap.set({ "n", "x", "o" }, "]c", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
            end, { desc = "Next class start" })

            vim.keymap.set({ "n", "x", "o" }, "[f", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
            end, { desc = "Prev function start" })

            vim.keymap.set({ "n", "x", "o" }, "[c", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
            end, { desc = "Prev class start" })

            vim.keymap.set("n", ">a", function()
                require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner", "textobjects")
            end, { desc = "Swap next parameter" })

            vim.keymap.set("n", "<a", function()
                require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner", "textobjects")
            end, { desc = "Swap prev parameter" })
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope-file-browser.nvim",
            "folke/todo-comments.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },

        cmd = "Telescope",
        keys = {
            {
                "<leader>ff",
                function() require("telescope.builtin").find_files() end,
                desc = "Find files",
            },
            {
                "<leader>fa",
                function()
                    require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
                end,
                desc = "Find all (hidden + ignored)",
            },
            {
                "<leader>fe",
                function()
                    require("telescope").extensions.file_browser.file_browser({
                        path = "%:p:h",
                        select_buffer = true,
                    })
                end,
                desc = "File browser",
            },
            {
                "<leader>fw",
                function()
                    require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
                end,
                desc = "Search word under cursor",
                mode = { "n", "v" },
            },
            {
                "<leader>fl",
                function() require("telescope.builtin").live_grep() end,
                desc = "Live grep",
            },
            {
                "<leader>fo",
                function() require("telescope.builtin").oldfiles() end,
                desc = "Recent files",
            },
            {
                "<leader>fc",
                function() require("telescope.builtin").commands() end,
                desc = "Command palette",
                mode = { "n", "v" },
            },
            {
                "<leader>ft",
                function() require("telescope").extensions["todo-comments"].todo() end,
                desc = "Search TODO comments",
            },
            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers({
                        sort_lastused = true,
                        show_all_buffers = true,
                    })
                end,
                desc = "Buffers",
            },
            {
                "<leader>fh",
                function() require("telescope.builtin").help_tags() end,
                desc = "Help tags",
            },
            {
                "<leader>fk",
                function() require("telescope.builtin").keymaps() end,
                desc = "Keymaps",
            },
            {
                "<leader>fr",
                function() require("telescope.builtin").registers() end,
                desc = "Registers",
            },
            {
                "<leader>pp",
                function()
                    local root = vim.fs.root(0, {
                        ".git", ".svn",
                        "pyproject.toml", "Cargo.toml", "go.mod",
                        "Makefile", "CMakeLists.txt", "meson.build",
                    }) or vim.uv.cwd()

                    require("telescope.builtin").find_files({
                        cwd = root,
                        prompt_title = "Project Files",
                        hidden = true,
                    })
                end,
                desc = "Project files",
            },
            {
                "<leader>pc",
                function()
                    local root = vim.fs.root(0, {
                        ".git",
                        "pyproject.toml", "Cargo.toml", "go.mod",
                        "Makefile", "CMakeLists.txt",
                    }) or vim.uv.cwd()

                    vim.cmd.lcd(root)
                    vim.notify("Project root: " .. root, vim.log.levels.INFO)
                end,
                desc = "Set project root (lcd)",
            },
        },

        config = function()
            local actions = require("telescope.actions")
            local fb_actions = require("telescope._extensions.file_browser.actions")

            require("telescope").setup({
                defaults = {
                    layout_strategy  = "horizontal",
                    sorting_strategy = "ascending",
                    layout_config = {
                        width           = 0.8,
                        height          = 0.8,
                        preview_cutoff  = 120,
                        prompt_position = "top",
                    },
                    preview = {
                        treesitter = true,
                    },
                    file_ignore_patterns = {
                        "node_modules", "dist", "build", "target", "%.git/",
                    },
                    border = true,
                    mappings = {
                        i = {
                            ["<A-a>"] = fb_actions.create,
                            ["<A-d>"] = fb_actions.remove,
                            ["<A-r>"] = fb_actions.rename,
                            ["<A-m>"] = fb_actions.move,
                            ["<A-c>"] = fb_actions.copy
                        },
                        n = {
                        	["d"] = actions.delete_buffer
                        },
                    },
                },

                pickers = {
                    find_files = { hidden = true },
                },

                extensions = {
                    fzf = {
                        fuzzy                   = true,
                        override_generic_sorter = true,
                        override_file_sorter    = true,
                        case_mode               = "smart_case",
                    },
                    file_browser = {
                        theme          = "dropdown",
                        hijack_netrw   = true,
                        hidden         = true,
                        no_ignore      = true,
                        layout_strategy = "horizontal",
                        layout_config  = {
                            horizontal = {
                                width         = 0.8,
                                height        = 0.8,
                                preview_width = 0.5,
                            },
                        },
                        mappings = {
                            i = {
                                ["<A-a>"] = fb_actions.create,
                                ["<A-d>"] = fb_actions.remove,
                                ["<A-r>"] = fb_actions.rename,
                                ["<A-m>"] = fb_actions.move,
                                ["<A-c>"] = fb_actions.copy,
                            },
                        },
                    },
                },
            })

            require("telescope").load_extension("fzf")
            require("telescope").load_extension("file_browser")
        end,
    },
    {
        "stevearc/aerial.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("aerial").setup({
                backends = { "treesitter" },
                layout = {
                    min_width         = 24,
                    default_direction = "right",
                },
                update_events = "TextChanged,InsertLeave",
                show_guides   = true,
                icons = {
                    Function    = "ƒ",
                    Method      = "𝓜",
                    Constructor = "",
                    Class       = "𝓒",
                    Interface   = "",
                    Struct      = "𝓢",
                    Enum        = "",
                    EnumMember  = "",

                    Variable    = "",
                    Field       = "",
                    Property    = "",
                    Constant    = "",

                    Module      = "",
                    Package     = "",
                    Namespace   = "",

                    TypeParameter = "",
                    Event       = "",
                    Operator    = "",

                    Array       = "",
                    Boolean     = "",
                    Null        = "∅",
                    Number      = "#",
                    Object      = "",
                    String      = "",
                    Key         = "",
                },
            })

            vim.keymap.set("n", "<leader>ae", "<cmd>AerialToggle!<CR>",
                { noremap = true, silent = true, desc = "Toggle Aerial outline" })
        end,
    },

    -- [[ CODING ]]
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require('cmp')
            require("luasnip.loaders.from_vscode").lazy_load()

            local kind_icons = {
                Text = "",
                Method = "󰆧",
                Function = "󰡱",
                Constructor = "",
                Field = "󰜢",
                Variable = "󰀫",
                Class = "",
                Interface = "",
                Module = "󰕳",
                Property = "",
                Unit = "",
                Value = "󰎠",
                Enum = "",
                Keyword = "󰌋",
                Snippet = "󰘍",
                Color = "",
                File = "󰈙",
                Reference = "",
                Folder = "󰉋",
                EnumMember = "",
                Constant = "󰏿",
                Struct = "󰙅",
                Event = "",
                Operator = "󰆕",
                TypeParameter = "",
            }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ['<CR>']    = cmp.mapping.confirm({ select = true }),
                    ['<Tab>']   = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                    ['<C-b>']   = cmp.mapping.scroll_docs(-4),
                    ['<C-f>']   = cmp.mapping.scroll_docs(4),
                    ['<C-e>']   = cmp.mapping.abort(),
                },
                formatting = {
                    format = function(entry, item)
                        item.kind = (kind_icons[item.kind] or "") .. " " .. item.kind
                        return item
                    end,
                },
                sources = cmp.config.sources({
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'luasnip' },
                }),
            })
        end,
    },

    -- [[ UTILITY ]]
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
            local keys = {
                OPENAI  = "OPENAI_API_KEY",
                CLAUDE  = "ANTHROPIC_API_KEY",
            }
            for name, var in pairs(keys) do
                local val = os.getenv(var)
                if val and val ~= "" then
                    return true
                end
            end
            vim.schedule(function()
                vim.notify("Avante disabled: no API key found (OPENAI_API_KEY or ANTHROPIC_API_KEY)", vim.log.levels.WARN)
            end)
            return false
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
                openai = {
                    endpoint = "https://api.openai.com/v1",
                    model = "gpt-4o-mini",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_tokens = 8192,
                    },
                },
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
        "folke/which-key.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                plugins = {
                    spelling = { enabled = true, suggestions = 20 },
                },
                triggers = {
                    { "<leader>", mode = { "n", "v" } },
                    { "<A-",     mode = { "n" } },
                    { "[",       mode = { "n" } },
                    { "]",       mode = { "n" } },
                },
                show_help = false,
                win = {
                    border = "rounded",
                },
            })
        end,
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
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
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",

        config = function()
            require("nvim-surround").setup({})
        end,
    }
}
