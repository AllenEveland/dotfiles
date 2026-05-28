return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require('cmp')

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
                },
                formatting = {
                    format = function(entry, item)
                        item.kind = (kind_icons[item.kind] or "") .. " " .. item.kind
                        return item
                    end,
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'luasnip' },
                }),
            })
        end,
    },

    {
        "mason-org/mason.nvim",
        lazy = false,
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({
                log_level = vim.log.levels.WARN,
                ui = {
                    border = "none",
                    check_outdated_packages_on_open = true,
                },
                max_concurrent_installers = 1,
            })
        end,
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp"
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(_, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            end

            -- [[ LSP for C,C++ ]]
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--cross-file-rename",
                },
                root_markers = {
                    "compile_commands.json",
                    "compile_flags.txt",
                    ".clangd",
                    ".git",
                },
                capabilities = capabilities,
                on_attach = on_attach,
                init_options = {
                    clangdFileStatus = true,
                },
            })
            vim.lsp.enable("clangd")

            -- [[ LSP for Python ]]
            vim.lsp.config("pyright", {
                root_markers = {
                    "pyrightconfig.json",
                    "pyproject.toml",
                    "setup.py",
                    "requirements.txt",
                    ".git",
                },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = "basic",
                        },
                        venvPath = ".",
                        venv = ".venv",
                    },
                },
            })
            vim.lsp.enable("pyright")

            -- [[ LSP for Lua ]]
            vim.lsp.config("lua_ls", {
                cmd = { "lua-language-server" },
                root_markers = {
                    ".luarc.json",
                    ".luarc.jsonc",
                    ".luacheckrc",
                    "stylua.toml",
                    ".stylua.toml",
                    "selene.toml",
                    ".git",
                },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        runtime = {
                            version = "Lua 5.4",
                        },
                        diagnostics = {
                            enable = true,
                        },
                        workspace = {
                            checkThirdParty = false,
                        },
                        completion = {
                            callSnippet = "Replace",
                            keywordSnippet = "Replace",
                        },
                        hint = {
                            enable = true,
                            setType = true,
                            paramType = true,
                            paramName = "All",
                            arrayIndex = "Auto",
                        },
                        format = {
                            enable = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })
            vim.lsp.enable("lua_ls")

            vim.diagnostic.config({
                virtual_text = true,
                signs = false,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN]  = " ",
                        [vim.diagnostic.severity.INFO]  = " ",
                        [vim.diagnostic.severity.HINT]  = " ",
                    },
                },
            })
        end,
    },

    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        config = function()
            require("fidget").setup({
                progress = {
                    display = {
                        done_ttl = 3,
                    },
                },
                notification = {
                    window = {
                        winblend = 100,
                    },
                },
            })
        end,
    },

    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = { "BufReadPost", "BufNewFile" },
        cmd = "Trouble",
        opts = {
            use_diagnostic_signs = true,
            auto_open = false,
            auto_close = false,
            auto_preview = false,
            auto_fold = false,
        },
        config = function(_, opts)
            require("trouble").setup(opts)
        end,
        keys = {
            { "<leader>td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<leader>tb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>tq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        },
    },
}
