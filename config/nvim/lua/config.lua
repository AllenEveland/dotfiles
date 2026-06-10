-- [[Option]]
vim.opt.compatible = false
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.timeoutlen = 300
vim.opt.updatetime = 200
vim.opt.ttimeoutlen = 0
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars = { eob=" " }
vim.opt.whichwrap:append("<,>,[,],h,l")
vim.opt.laststatus = 3
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 20
vim.g.mapleader = " "

-- [[Autocmd]]
local function set_transparent()
    local hl = vim.api.nvim_set_hl

    hl(0, "CursorLine",   { bg = "none" })
    hl(0, "CursorLineNr", { bg = "none" })
    hl(0, "LineNr",       { bg = "none" })
    hl(0, "SignColumn",   { bg = "none" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.schedule(set_transparent)
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = set_transparent,
})

-- [[Keymap]]
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<C-Left>', '<CMD>vertical resize -1<CR>', opts)
vim.keymap.set('n', '<C-Right>', '<CMD>vertical resize +1<CR>', opts)
vim.keymap.set('n', '<C-Down>', '<CMD>resize +1<CR>', opts)
vim.keymap.set('n', '<C-Up>', '<CMD>resize -1<CR>', opts)

vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

vim.keymap.set('n', '<C-z>', 'u', opts)
vim.keymap.set('i', '<C-z>', '<Esc>u', opts)
vim.keymap.set('v', '<C-z>', '<Esc>u', opts)
vim.keymap.set('n', '<C-y>', '<C-r>', opts)
vim.keymap.set('i', '<C-y>', '<Esc><C-r>', opts)
vim.keymap.set('v', '<C-y>', '<Esc><C-r>', opts)

vim.keymap.set('n', '<leader>nh', ':noh<CR><Esc>', opts)

vim.keymap.set('n', '<C-s>', ':w<CR>', opts)

vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)

vim.keymap.set('n', '<leader>x', ':bdelete<CR>', opts)
vim.keymap.set('n', '<leader>qq', ':q!<CR>', opts)

-- [[Plugin Manager]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
            }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    checker = { enabled = true },
})
