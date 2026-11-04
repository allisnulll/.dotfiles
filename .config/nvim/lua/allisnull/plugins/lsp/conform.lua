return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "mdformat" },
                php = { "pint" },
                zsh = { "beautysh" },
            },
        })

        local format = function() conform.format({ lsp_format = "fallback" }) end

        vim.keymap.set({ "n", "v" }, "<leader>l", "", { desc = "Lint/Format" })
        vim.keymap.set({ "n", "v" }, "<leader>lf", format, { desc = "Format file or Range (visual mode)" })

        vim.api.nvim_create_augroup("format", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.go" },
            group = "format",
            callback = format,
        })
    end,
}
