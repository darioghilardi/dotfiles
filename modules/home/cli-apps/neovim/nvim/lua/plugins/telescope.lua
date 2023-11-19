return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>pf",
        function()
          require("telescope.builtin").find_files({ cwd = false })
        end,
        desc = "Find Files (cwd)",
      },
    },
  },
}
