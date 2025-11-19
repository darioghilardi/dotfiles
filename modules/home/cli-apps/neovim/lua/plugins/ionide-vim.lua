return {
  "Ionide-vim",
  enabled = nixCats("fsharp") or false,
  filetypes = { "fs", "fsx" },
  after = function()
    vim.g["fsharp#backend"] = "nvim"
  end,
}
