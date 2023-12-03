vim9script

import autoload "kg8m/configure/colors.vim"
import autoload "kg8m/util/string.vim" as stringUtil

# https://github.com/tpope/vim-markdown
export def Run(): void
  g:markdown_fenced_languages = [
    "cpp",
    "css",
    "diff",
    "html",
    "java",
    "javascript", "js=javascript",
    "python",
    "ruby", "rb=ruby",
    "sh",
    "sql",
    "typescript", "ts=typescript",
    "vim",
  ]
  g:markdown_syntax_conceal = false
  g:markdown_minlines = colors.SYNC_MINLINES

  augroup vimrc-configure-filetypes-markdown
    autocmd!
    autocmd Syntax markdown Syntax()
    autocmd SafeState * FixIskeyword()
  augroup END
enddef

def Syntax(): void
  # Support highlighting fenced code blocks in quoteblocks as follows:
  #
  #   > ```
  #   > something
  #   > ```
  #
  # https://github.com/vim/vim/blob/e86190e7c1297da29d0fc2415fdeca5ecae8d2ba/runtime/syntax/markdown.vim#L123
  syntax region markdownCodeBlock matchgroup=markdownCodeDelimiter start="^\z(\%(>\|\s\)\+\s*`\{3,\}\).*$" end="^\z1\s*\ze\s*$" keepend

  # Support highlighting fenced code block languages in quoteblocks as follows:
  #
  #   > ```vim
  #   > autocmd SomeEvent some_filetype SomeFunction()
  #   > ```
  #
  for type in g:markdown_fenced_languages
    # https://github.com/vim/vim/blob/e86190e7c1297da29d0fc2415fdeca5ecae8d2ba/runtime/syntax/markdown.vim#L134
    execute 'syntax region markdownHighlight_' .. substitute(matchstr(type, '[^=]*$'), '\..*', '', '') .. ' matchgroup=markdownCodeDelimiter start="^\z(\%(>\|\s\)\+\s*`\{3,\}\)\s*\%({.\{-}\.\)\=' .. matchstr(type, '[^=]*') .. '}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight_' .. tr(matchstr(type, '[^=]*$'), '.', '_')
  endfor

  # Support highlighting inline codes.
  highlight default link markdownCode String
enddef

def FixIskeyword(): void
  if &filetype !=# "markdown"
    return
  endif

  if !stringUtil.Includes(&iskeyword, "#")
    return
  endif

  # Remove `#` from `iskeyword` that is set in a built-in `syntax/typescriptcommon.vim`.
  setlocal iskeyword-=#
enddef
