-- Inital config
local opts = { noremap = true, silent = true }

-- Resize buffer
vim.keymap.set('n', '<C-Left>', '<CMD>vertical resize -1<CR>', opts)
vim.keymap.set('n', '<C-Right>', '<CMD>vertical resize +1<CR>', opts)
vim.keymap.set('n', '<C-Down>', '<CMD>resize +1<CR>', opts)
vim.keymap.set('n', '<C-Up>', '<CMD>resize -1<CR>', opts)

-- Move to buffer
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Undo/redo
vim.keymap.set('n', '<C-z>', 'u', opts)
vim.keymap.set('i', '<C-z>', '<Esc>u', opts)
vim.keymap.set('v', '<C-z>', '<Esc>u', opts)
vim.keymap.set('n', '<C-y>', '<C-r>', opts)
vim.keymap.set('i', '<C-y>', '<Esc><C-r>', opts)
vim.keymap.set('v', '<C-y>', '<Esc><C-r>', opts)

-- Disable nohighlight
vim.keymap.set('n', '<leader>nh', ':noh<CR><Esc>', opts)

-- Split buffer
vim.keymap.set('n', '<F1>', ':sp<CR>', opts)
vim.keymap.set('n', '<F2>', ':vs<CR>', opts)

-- Save
vim.keymap.set('n', '<C-s>', ':w<CR>', opts)

-- Buffer manager
vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)

vim.keymap.set('n', '<leader>x', ':bdelete<CR>', opts)

-- Force quit fast
vim.keymap.set('n', '<leader>qq', ':q!<CR>', opts)

