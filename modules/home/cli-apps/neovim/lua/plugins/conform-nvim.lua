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
        timeout_ms = 1000,
      },
      formatters_by_ft = {
        lua = nixCats("lua") and { "stylua" } or nil,
        elixir = nixCats("elixir") and { "mix" } or nil,
        nix = nixCats("nix") and { "alejandra" } or nil,
        fsharp = nixCats("fsharp") and { "fantomas" } or nil,
        javascript = nixCats("javascript") and { "biome" } or nil,
        css = nixCats("css") and { "biome" } or nil,
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
