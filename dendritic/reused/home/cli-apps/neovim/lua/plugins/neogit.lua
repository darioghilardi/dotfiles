return {
  "neogit",
  enabled = nixCats("general") or false,
  keys = {
    { "<leader>gs", "<cmd>Neogit kind=auto<cr>", mode = { "n" }, desc = "Neogit" },
  },
  after = function()
    require("neogit").setup()
  end,
}
