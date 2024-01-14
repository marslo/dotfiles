require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "bash", "groovy", "java", "yaml", "xml", "cmake", "css", "dockerfile", "git_config", "gitcommit", "gitignore", "jq", "json", "markdown", "ssh_config" },
  sync_install = false,
  auto_install = true,
  ignore_install = { "javascript" },
  indent = {
    enable = true,
    disable = { "markdown" },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  highlight = {
    enable = true,
    disable = { "markdown" },
    additional_vim_regex_highlighting = false,
  },
}
require("nvim-treesitter.install").prefer_git = true
