vim9script

# https://github.com/tpope/vim-markdown
export def Run(): void
  g:markdown_fenced_languages = [
    "css",
    "diff",
    "html",
    "javascript", "js=javascript",
    "ruby", "rb=ruby",
    "sh",
    "sql",
    "typescript", "ts=typescript",
    "vim",
  ]
  g:markdown_syntax_conceal = false
  g:markdown_minlines = g:kg8m#configure#colors#sync_minlines
enddef
