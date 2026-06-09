return {
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
                indent = {
                    enable = true,
                },
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
                swap = {
                    enable = true,
                },
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
                "<leader>ls",
                function() require("telescope.builtin").lsp_document_symbols() end,
                desc = "LSP document symbols",
            },
            {
                "<leader>lw",
                function() require("telescope.builtin").lsp_workspace_symbols() end,
                desc = "LSP workspace symbols",
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
                        prompt_position = "bottom",
                    },
                    preview = {
                        treesitter = true,
                    },
                    file_ignore_patterns = {
                        "node_modules", "dist", "build", "target", "%.git/",
                    },
                    border = true,
                    mappings = {
                        i = { ["<C-d>"] = actions.delete_buffer },
                        n = { ["dd"]    = actions.delete_buffer },
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
                backends = { "lsp", "treesitter" },
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
}
