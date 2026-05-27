return {
    {
        "mfussenegger/nvim-dap",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local dap = require("dap")

            dap.set_log_level("INFO")

            vim.fn.sign_define('DapBreakpoint',          { text = '●', texthl = 'DiagnosticError' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
            vim.fn.sign_define('DapBreakpointRejected',  { text = '✗', texthl = 'DiagnosticError' })
            vim.fn.sign_define('DapStopped',             { text = '→', texthl = 'DiagnosticInfo', linehl = 'Visual' })
            vim.fn.sign_define('DapLogPoint',            { text = '◆', texthl = 'DiagnosticHint' })

            dap.adapters.codelldb = {
                type = 'server',
                port = "${port}",
                executable = {
                    command = 'codelldb',
                    args = { "--port", "${port}" },
                }
            }

            dap.configurations.cpp = {
                {
                    name = "C/C++ debug",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                },
            }

            dap.configurations.c = dap.configurations.cpp

            dap.configurations.rust = {
                {
                    name = "Debug Rust",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.getcwd() .. "/target/debug/" .. vim.fn.input("Binary name: ")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }

            dap.adapters.python = {
                type = 'executable',
                command = 'python',
                args = { '-m', 'debugpy.adapter' },
            }

            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = "Python debug",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    console = "integratedTerminal",
                    stopOnEntry = true,
                    pythonPath = function()
                        local venv = os.getenv("VIRTUAL_ENV")
                        if venv then return venv .. "/bin/python" end
                        local conda = os.getenv("CONDA_PREFIX")
                        if conda then return conda .. "/bin/python" end
                        return "python3"
                    end,
                },
            }

            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
            vim.keymap.set("n", "<leader>dn", dap.step_over,         { desc = "DAP: step over" })
            vim.keymap.set("n", "<leader>di", dap.step_into,         { desc = "DAP: step into" })
            vim.keymap.set("n", "<leader>do", dap.step_out,          { desc = "DAP: step out" })
            vim.keymap.set("n", "<leader>dt", dap.terminate,         { desc = "DAP: terminate" })

            vim.keymap.set("n", "<leader>dc", function()
                require("lazy").load({ plugins = { "nvim-dap-ui" } })
                require("dap").continue()
            end, { desc = "DAP: start/continue" })
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio", },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end

            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end
    }
}
