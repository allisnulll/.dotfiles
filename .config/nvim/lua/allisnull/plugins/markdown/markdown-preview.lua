return {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function(plugin)
        vim.opt.rtp:append(plugin.dir)
        vim.fn["mkdp#util#install"](1)
    end,
    init = function()
        vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", { desc = "MarkdownPreviewToggle" })
    end,
}
