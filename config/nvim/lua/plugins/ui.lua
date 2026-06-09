return {
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        config = function()
            require("onedark").setup({
                style          = "warmer",
                transparent    = true,
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
                    lualine_x = {
                        {
                            function()
                                local clients = vim.lsp.get_clients({ bufnr = 0 })
                                if #clients == 0 then return "" end
                                return "  " .. clients[1].name
                            end,
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " " },
                        },
                    },
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
                    lualine_x = {
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            sections = { "error", "warn" },
                            symbols = { error = " ", warn = " " },
                            diagnostics_color = {
                                error = { fg = "#e06c75" },
                                warn  = { fg = "#d19a66" },
                            },
                        },
                    },
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
}
