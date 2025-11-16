return {
  "elixir-tools.nvim",
  enabled = nixCats('elixir') or false,
  filetypes = { 'ex', 'exs', 'heex' },
  after = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = { enable = false },

      elixirls = {
        enable = true,
        settings = elixirls.settings {
          dialyzerEnabled = false,
          enableTestLenses = true,
        }
      }
    }
  end
}
