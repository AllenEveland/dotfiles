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
        opts = {},
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
                -- Main language
                "python", "c", "cpp", "asm", "llvm",

                -- Other important script language
                "bash",

                -- Build language
                "cmake", "make",
                "ninja",
                "dockerfile",

                -- Advanced shell
                "awk", "regex",

                -- Other
                "javascript", "typescript", "json",
                "markdown", "markdown_inline",
                "query",

                -- Config file
                "yaml", "toml",
                "ini", "gitignore",
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
                pattern = { "*" },
                callback = function(args)
                    local buf = args.buf
                    local max_lines    = 50000
                    local max_filesize = 10 * 1024 * 1024

                    local too_large = vim.api.nvim_buf_line_count(buf) > max_lines
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        too_large = true
                    end

                    if not too_large then
                        pcall(vim.treesitter.start, buf)
                    else
                        vim.notify("ERROR: File too large to parsing", vim.log.levels.ERROR)
                    end

                    vim.wo[0][0].foldmethod = "expr"
                    vim.wo[0][0].foldexpr   = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldenable = false
                end,
            })

            vim.keymap.set({ "n", "x", "o" }, "]f", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]c", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[f", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[c", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
            end)

            vim.keymap.set("n", ">a", function()
                require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner", "textobjects")
            end)
            vim.keymap.set("n", "<a", function()
                require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner", "textobjects")
            end)
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },

        cmd = "Telescope",
        keys = {
            {
                "<leader>ff",
                function()
                    require("telescope.builtin").find_files()
                end,
                desc = "Find files",
                mode = "n",
            },

            {
                "<leader>fa",
                function()
                    require("telescope.builtin").find_files({
                        hidden = true,
                        no_ignore = true,
                    })
                end,
                desc = "Find all (hidden + ignored)",
                mode = "n",
            },

            {
                "<leader>fe",
                function()
                    require("telescope").extensions.file_browser.file_browser({
                        path = "%:p:h",
                        select_buffer = true,
                    })
                end,
                desc = "File Browser",
                mode = "n",
            },

            {
                "<leader>fw",
                function()
                    require("telescope.builtin").grep_string({
                        search = vim.fn.expand("<cword>")
                    })
                end,
                desc = "Search word under cursor",
                mode = { "n", "v" },
            },

            {
                "<leader>fl",
                function()
                    require("telescope.builtin").live_grep()
                end,
                desc = "Live grep",
                mode = "n",
            },

            {
                "<leader>fo",
                function()
                    require("telescope.builtin").oldfiles()
                end,
                desc = "Old files",
                mode = "n",
            },

            {
                "<leader>fc",
                function()
                    require("telescope.builtin").commands()
                end,
                desc = "Command palette",
                mode = { "n", "v" },
            },

            {
                "<leader>ft",
                function()
                    require("telescope").extensions["todo-comments"].todo()
                end,
                desc = "Search TODO-Comment",
                mode = "n",
            },

            {
                "<leader>li",
                function()
                    require("telescope.builtin").lsp_implementations()
                end,
                desc = "LSP Implementations",
                mode = "n",
            },

            {
                "<leader>ls",
                function()
                    require("telescope.builtin").lsp_document_symbols()
                end,
                desc = "Document Symbols",
                mode = "n",
            },

            {
                "<leader>lw",
                function()
                    require("telescope.builtin").lsp_workspace_symbols()
                end,
                desc = "Workspace Symbols",
                mode = "n",
            },

            {
                "<leader>fb",
                function()
                    require("telescope.builtin").buffers({
                        sort_lastused = true,
                        ignore_current_buffer = false,
                        show_all_buffers = true,
                        previewer = true,
                        initial_mode = "insert",
                        mappings = {
                            i = {
                                ["<C-d>"] = require("telescope.actions").delete_buffer,
                            },
                            n = {
                                ["dd"] = require("telescope.actions").delete_buffer,
                            },
                        },
                    })
                end,
                desc = "Buffers",
                mode = "n",
            },

            {
                "<leader>fh",
                function()
                    require("telescope.builtin").help_tags()
                end,
                desc = "Help Tags",
                mode = "n",
            },

            {
                "<leader>fk",
                function()
                    require("telescope.builtin").keymaps()
                end,
                desc = "Keymaps",
                mode = "n",
            },

            {
                "<leader>fr",
                function()
                    require("telescope.builtin").registers()
                end,
                desc = "Registers",
                mode = "n",
            },

            {
                "<leader>pp",
                function()
                    local root = vim.fs.root(0, {
                        ".git",
                        ".svn",
                        "pyproject.toml",
                        "Cargo.toml",
                        "go.mod",
                        "Makefile",
                        "CMakeLists.txt",
                        "meson.build",
                        "README.md",
                    }) or vim.loop.cwd()

                    require("telescope.builtin").find_files({
                        cwd = root,
                        prompt_title = "Project Files",
                        hidden = true,
                    })
                end,
                desc = "Project files",
                mode = "n",
            },

            {
                "<leader>pc",
                function()
                    local root = vim.fs.root(0, {
                        ".git",
                        "pyproject.toml",
                        "Cargo.toml",
                        "go.mod",
                        "Makefile",
                        "CMakeLists.txt",
                    }) or vim.loop.cwd()

                    vim.cmd.lcd(root)
                    print("Project root: " .. root)
                end,
                desc = "Set project root",
                mode = "n",
            },
        },

        config = function()
            require("telescope").setup({
                defaults = {
                    layout_strategy = "horizontal",
                    sorting_strategy = "ascending",

                    layout_config = {
                        width = 0.8,
                        height = 0.8,
                        preview_cutoff = 120,
                        prompt_position = "top",
                    },

                    preview = {
                        treesitter = true,
                    },

                    file_ignore_patterns = {
                        "node_modules",
                        "dist",
                        "build",
                        "target",
                        "%.git/",
                    },

                    border = true,
                },
                pickers = {
                    find_files = {
                        hidden = true,
                        previewer = true,
                    },
                    live_grep = {
                        previewer = true,
                    },
                    buffers = {
                        previewer = true,
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    file_browser = {
                        theme = "dropdown",
                        hijack_netrw = true,
                        hidden = true,
                        no_ignore = true,
                        layout_strategy = "horizontal",
                            layout_config = {
                                horizontal = {
                                    width = 0.8,
                                    height = 0.8,
                                    preview_width = 0.5,
                                },
                        },
                        mappings = {
                            ["i"] = {
                                ["<A-a>"] = require("telescope._extensions.file_browser.actions").create,
                                ["<A-d>"] = require("telescope._extensions.file_browser.actions").remove,
                                ["<A-r>"] = require("telescope._extensions.file_browser.actions").rename,
                                ["<A-m>"] = require("telescope._extensions.file_browser.actions").move,
                                ["<A-c>"] = require("telescope._extensions.file_browser.actions").copy,
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
        event = { "BufReadPost", "BufNewFile" },

        config = function()
            require("aerial").setup({
                backends = { "lsp", "treesitter" },
                layout = {
                    min_width = 24,
                    default_direction = "right",
                },
                update_events = "TextChanged,InsertLeave",
                show_guides = true,
                icons = {
                    Function = "ƒ",
                    Class = "𝓒",
                    Variable = "",
                },
            })

            vim.keymap.set("n", "<leader>ae", "<cmd>AerialToggle!<CR>", { noremap = true, silent = true, desc = "Toggle Aerial outline" })
        end,
    },
}
