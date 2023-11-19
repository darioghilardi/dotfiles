-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n" }, "<leader>fs", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set({ "n" }, "<leader>wv", "<cmd>vs<cr>", { desc = "Split window vertically" })
vim.keymap.set({ "n" }, "<leader>ws", "<cmd>sv<cr>", { desc = "Split window horizontally" })
