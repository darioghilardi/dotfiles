return {
  "lualine.nvim",
  enabled = nixCats("general") or false,
  -- cmd = { "" },
  event = "DeferredUIEnter",
  -- ft = "",
  -- keys = "",
  -- colorscheme = "",
  load = function(name)
    vim.cmd.packadd(name)
    vim.cmd.packadd("lualine-lsp-progress")
  end,
  after = function(plugin)
    require("lualine").setup({
      options = {
        icons_enabled = false,
        theme = "onedark",
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1,
            status = true,
          },
        },
      },
      inactive_sections = {
        lualine_b = {
          {
            "filename",
            path = 3,
            status = true,
          },
        },
        lualine_x = { "filetype" },
      },
      tabline = {
        lualine_a = { "filename" },
        lualine_b = { "lsp_progress" },
        lualine_z = { "tabs" },
      },
    })
  end,
}
