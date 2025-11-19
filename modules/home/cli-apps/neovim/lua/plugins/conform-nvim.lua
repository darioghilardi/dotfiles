return {
  "conform.nvim",
  enabled = nixCats("general") or false,
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "<leader>FF", desc = "[F]ormat [F]ile" },
  },
  after = function(plugin)
    local conform = require("conform")

    conform.setup({
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 500,
      },
      formatters_by_ft = {
        lua = nixCats("lua") and { "stylua" } or nil,
        elixir = nixCats("elixir") and { "mix" },
      },
      formatters = {
        stylua = {
          args = {
            "--indent-type",
            "Spaces",
            "--indent-width",
            "2",
            "-",
          },
        },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>FF", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "[F]ormat [F]ile" })
  end,
}
