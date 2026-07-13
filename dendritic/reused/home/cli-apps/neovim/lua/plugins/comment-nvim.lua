return {
  "Comment.nvim",
  enabled = nixCats("general") or false,
  after = function()
    require("Comment").setup()
  end,
}
