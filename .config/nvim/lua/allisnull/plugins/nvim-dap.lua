return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "theHamsta/nvim-dap-virtual-text",
        "igorlfs/nvim-dap-view",
    },
    keys = {
        { "<M-d><M-d>", ":DapViewToggle<CR>", { desc = "DapViewToggle" }},
        { "<F9>", ":DapStepInto<CR>", { desc = "DapStepInto" }},
        { "<F8>", ":DapStepOver<CR>", { desc = "DapStepOver" }},
        { "<F7>", ":DapStepOut<CR>", { desc = "DapStepOut" }},
        { "<M-d>c", ":DapContinue<CR>", { desc = "DapContinue" }},
        { "<M-d>b", ":DapToggleBreakpoint<CR>", { desc = "DapToggleBreakpoint" }},
        { "<M-d>w", function()
            vim.ui.input({ prompt = "DapViewWatch: " }, function(command)
                vim.fn.feedkeys(":DapViewWatch " .. command .. "\r")
            end)
        end, { desc = "DapViewWatch" }},
        { "<M-d>p", ":DapStepPause<CR>", { desc = "DapStepPause" }},
        { "<M-d>k", ":DapTerminate<CR>", { desc = "DapTerminate" }},
    },
    config = function()
        require("nvim-dap-virtual-text").setup({})

        local dap = require("dap")

        vim.keymap.set("n", "<M-d>r", dap.restart, { desc = "DapRestart" });
        vim.keymap.set("n", "<M-d>f", function()
            vim.ui.input({ prompt = "DapBreakpoint Condition: " }, function(condition)
                dap.set_breakpoint(condition)
            end)
        end, { desc = "DapSetConditionalBreakpoint" });

        dap.adapters = {
            gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
            },
            delve = function(callback, config)
                if config.mode == "remote" and config.request == "attach" then
                    callback({
                        type = "server",
                        host = config.host or "127.0.0.1",
                        port = config.port or "38697"
                    })
                else
                    callback({
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = "dlv",
                            args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
                            detached = vim.fn.has("win32") == 0,
                        }
                    })
                end
            end,
            ["rust-gdb"] = {
                type = "executable",
                command = "rust-gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
            },
        }

        dap.configurations = {
            c = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    args = {},
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
                {
                    name = "Select and attach to process",
                    type = "gdb",
                    request = "attach",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    pid = function()
                        local name = vim.fn.input("Executable name (filter): ")
                        return require("dap.utils").pick_process({ filter = name })
                    end,
                    cwd = "${workspaceFolder}"
                },
                {
                    name = "Attach to gdbserver :1234",
                    type = "gdb",
                    request = "attach",
                    target = "localhost:1234",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}"
                },
            },
            cpp = dap.configurations.c,
            go = {
                {
                    type = "delve",
                    name = "Debug",
                    request = "launch",
                    program = "${file}"
                },
                {
                    type = "delve",
                    name = "Debug test",
                    request = "launch",
                    mode = "test",
                    program = "${file}"
                },
                {
                    type = "delve",
                    name = "Debug test (go.mod)",
                    request = "launch",
                    mode = "test",
                    program = "./${relativeFileDirname}"
                },
            },
            rust = {
                {
                    name = "Launch",
                    type = "rust-gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    args = {},
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
                {
                    name = "Select and attach to process",
                    type = "rust-gdb",
                    request = "attach",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    pid = function()
                        local name = vim.fn.input("Executable name (filter): ")
                        return require("dap.utils").pick_process({ filter = name })
                    end,
                    cwd = "${workspaceFolder}"
                },
                {
                    name = "Attach to gdbserver :1234",
                    type = "rust-gdb",
                    request = "attach",
                    target = "localhost:1234",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}"
                },
            },
        }
    end,
}
