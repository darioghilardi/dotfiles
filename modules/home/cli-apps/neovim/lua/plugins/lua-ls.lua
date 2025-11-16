return {
  -- name of the lsp
  "lua_ls",
  enabled = nixCats('lua') or false,
  -- provide a table containing filetypes,
  -- and then whatever your functions defined in the function type specs expect.
  -- in our case, it just expects the normal lspconfig setup options.
  lsp = {
    -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
    filetypes = { 'lua' },
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { "nixCats", "vim", },
          disable = { 'missing-fields' },
        },
        telemetry = { enabled = false },
      },
    },
  },
  -- also these are regular specs and you can use before and after and all the other normal fields
}
