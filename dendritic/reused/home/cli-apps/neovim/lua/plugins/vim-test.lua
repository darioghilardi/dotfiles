return {
  "vim-test",
  enabled = nixCats("general") or false,
  keys = {
    { "<leader>ts", "<cmd>TestNearest<CR>", mode = { "n" }, desc = "Test under cursor" },
    { "<leader>tf", "<cmd>TestFile<CR>", mode = { "n" }, desc = "Test current file" },
    { "<leader>ta", "<cmd>TestSuite<CR>", mode = { "n" }, desc = "Test suite" },
    { "<leader>tl", "<cmd>TestLast<CR>", mode = { "n" }, desc = "Test last" },
    { "<leader>tv", "<cmd>TestVisit<CR>", mode = { "n" }, desc = "Test visit" },
    { "<C-o>", "<C-\\><C-n>", mode = { "t" }, desc = "Activate scroll in terminal mode" },
  },
  after = function()
    vim.g["test#strategy"] = "neovim"
  end,
}
