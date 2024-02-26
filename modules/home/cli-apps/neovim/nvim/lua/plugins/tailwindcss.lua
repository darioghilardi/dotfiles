return {
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          tailwind = true,
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "js-everts/cmp-tailwind-colors", config = true },
    },
    opts = function(_, opts)
      -- original LazyVim kind icon formatter
      opts.formatting = {
        fields = { "kind", "abbr", "menu" },

        format = function(entry, item)
          item.menu = item.kind
          item = require("cmp-tailwind-colors").format(entry, item)
          local icons = require("lazyvim.config").icons.kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end
          return item
        end,
      }
    end,
  },
}
