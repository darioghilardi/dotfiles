return {
  "elixir-tools.nvim",
  enabled = nixCats("elixir") or false,
  filetypes = { "ex", "exs", "heex" },
  after = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup({
      nextls = { enable = false },

      elixirls = {
        enable = true,
        cmd = "/nix/store/cfb1qhw9i4iz3qhjvf2gmw27sj3cd1df-elixir-ls-0.29.3/bin/elixir-ls",
        settings = elixirls.settings({
          dialyzerEnabled = false,
          enableTestLenses = true,
        }),
      },
    })
  end,
}
