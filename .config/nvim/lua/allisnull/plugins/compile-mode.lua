return {
    "ej-shafran/compile-mode.nvim",
    branch = "nightly",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "m00qek/baleia.nvim",
    },
    config = function()
        vim.g.compile_mode = {
            default_command = "",
            ask_about_save = false,
            ask_to_interrupt = false,
            auto_jump_to_first_error = true,
            auto_scroll = false,
            baleia_setup = true,
            bang_expansion = true,
        }

        local compile_mode = require("compile-mode")

        local function find_build_exec()
            local handle = vim.uv.fs_scandir("build")
            if not handle then return nil end

            while true do
                local name, type = vim.uv.fs_scandir_next(handle)
                if not name then break end
                if type == "file" and vim.uv.fs_access("build/" .. name, "X") then
                    return "build/" .. name
                end
            end

            return nil
        end

        vim.keymap.set("n", "<F5>", function()
            local fallback = "build/" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
            vim.ui.input({
                prompt = "Compile command: ",
                default = "./build.sh && " .. (find_build_exec() or fallback)
            }, function(command)
                if command and command ~= "" then
                    vim.cmd("vert Compile " .. command)
                    vim.defer_fn(compile_mode.send_to_qflist, 300)
                end
            end)
        end, { desc = "Compile Mode" })
        vim.keymap.set("n", "<F6>", function()
            vim.cmd("vert Recompile")
            vim.defer_fn(compile_mode.send_to_qflist, 300)
        end, { desc = "Recompile Mode" })
    end
}
