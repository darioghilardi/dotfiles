-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n" }, "<leader>fs", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set({ "n" }, "<leader>wv", "<cmd>vs<cr>", { desc = "Split window vertically" })
vim.keymap.set({ "n" }, "<leader>ws", "<cmd>sv<cr>", { desc = "Split window horizontally" })
vim.keymap.set({ "n" }, "<leader>wh", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set({ "n" }, "<leader>wl", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set({ "n" }, "<leader>wk", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set({ "n" }, "<leader>wj", "<C-w>j", { desc = "Move to lower window" })

vim.keymap.set({ "i" }, "fd", "<esc>", { silent = true, desc = "Back to normal mode" })
