require('nvim-treesitter.configs').setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "bash", "groovy", "java", "yaml", "xml", "cmake", "css", "dockerfile", "git_config", "gitcommit", "gitignore", "git_rebase", "jq", "json", "markdown", "ssh_config", "vimdoc", "ini", "diff" },
  sync_install = true,
  auto_install = true,
  ignore_install = { "javascript" },
  indent = {
    enable = true,
    disable = { "markdown", "groovy", "Groovy" },
  },
  highlight = {
    enable = true,
    disable = { "markdown", "groovy" },
    additional_vim_regex_highlighting = true,
    ["punctuation.bracket"] = "",
    ["constructor"]         = "",
  },
  incremental_selection = {
    enable = false,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      node_decremental = "<BS>",
      scope_incremental = "<TAB>",
    },
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  }
}
require("nvim-treesitter.install").prefer_git = true
