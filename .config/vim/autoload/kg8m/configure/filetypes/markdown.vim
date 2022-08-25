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

  augroup vimrc-configure-filetypes-markdown
    autocmd!
    autocmd SafeState * FixIskeyword()
  augroup END
enddef

def FixIskeyword(): void
  if &filetype !=# "markdown"
    return
  endif

  if !kg8m#util#string#Includes(&iskeyword, "#")
    return
  endif

  # Remove `#` from `iskeyword` that is set in a built-in `syntax/typescriptcommon.vim`.
  setlocal iskeyword-=#
enddef
