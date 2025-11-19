return {
  "mini.nvim",
  enabled = nixCats("general") or false,
  event = "DeferredUIEnter",
  after = function(plugin)
    require("mini.pairs").setup()
    require("mini.icons").setup()
    require("mini.ai").setup()
  end,
}
