vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.cursorline = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.backspace = "indent,eol,start"

vim.opt.nrformats = "unsigned,bin,hex"

vim.opt.swapfile = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true
vim.opt.undolevels = 5000

vim.opt.updatetime = 500

vim.opt.listchars = {
    space = "◦",
    tab = "»—",
    extends = "→",
    precedes = "←",
    nbsp = "␣",
    trail = "×",
    eol = "⏎",
}

vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = "",
    foldinner = " ",
}

vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.g.easy_align_ignore_groups = {}

vim.g["conjure#highlight#enabled"] = true

if vim.g.neovide then
    vim.keymap.set({ "n", "v" }, "<C-p>", '"+p', { desc = "Paste" })
    vim.keymap.set({ "c", "i" }, "<C-p>", "<C-r>+", { desc = "Paste" })

    vim.keymap.set("n", "<F11>", function()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
    end, { desc = "Toggle Neovide fullscreen" })

    vim.o.guifont = "Maple Mono NF:h12"
    vim.keymap.set({ "n", "i" }, "<C-->", function()
        if vim.o.guifont ~= nil then
            local font_size = tonumber(vim.o.guifont:match("%d+$"))
            font_size = math.max(0, font_size - 1)
            vim.o.guifont = "Maple Mono NF:h" .. tostring(font_size)
            print(font_size)
        else
            vim.o.guifont = "Maple Mono NF:h12"
        end
    end, { desc = "Decrease Font Size" })
    vim.keymap.set({ "n", "i" }, "<C-=>", function()
        if vim.o.guifont ~= nil then
            local font_size = tonumber(vim.o.guifont:match("%d+$"))
            font_size = font_size + 1
            vim.o.guifont = "Maple Mono NF:h" .. tostring(font_size)
            print(font_size)
        else
            vim.o.guifont = "Maple Mono NF:h12"
        end
    end, { desc = "Increase Font Size" })

    vim.g.neovide_opacity = 0.75
    vim.keymap.set({ "n", "i" }, "<M-->", function()
        if vim.g.neovide_opacity ~= nil then
            vim.g.neovide_opacity = math.max(0, vim.g.neovide_opacity - 0.05)
        else
            vim.g.neovide_opacity = 0.75
        end
    end, { desc = "Lower Opacity" })
    vim.keymap.set({ "n", "i" }, "<M-=>", function()
        if vim.g.neovide_opacity ~= nil then
            vim.g.neovide_opacity = math.min(1, vim.g.neovide_opacity + 0.05)
        else
            vim.g.neovide_opacity = 0.75
        end
    end, { desc = "Raise Opacity" })

    vim.g.neovide_padding_top = 8
    vim.g.neovide_padding_bottom = 8
    vim.g.neovide_padding_right = 8
    vim.g.neovide_padding_left = 8
    vim.g.neovide_refresh_rate = 144
    vim.g.neovide_cursor_animation_length = 0.04
    vim.g.neovide_cursor_trail_size = 0.7
    -- vim.g.neovide_cursor_vfx_mode = "sonicboom"
end
