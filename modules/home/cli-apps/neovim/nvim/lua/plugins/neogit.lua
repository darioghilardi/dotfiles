return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    config = true,
    keys = {
      {
        "<leader>gs",
        function()
          require("neogit").open({ kind = "vsplit" })
        end,
        desc = "Neogit Open",
      },
    },
  },
}
