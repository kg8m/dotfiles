" https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
function kg8m#plugin#yankround#fzf#list() abort  " {{{
  return range(0, len(g:_yankround_cache) - 1)->map("s:format_list_item(v:val)")
endfunction  " }}}

function kg8m#plugin#yankround#fzf#preview_command() abort  " {{{
  let command  = "echo {}"
  let command .= " | sed -e 's/^ *[0-9]\\{1,\\}\t//' -e 's/\\\\/\\\\\\\\/g'"
  let command .= " | head -n5"

  return command
endfunction  " }}}

function kg8m#plugin#yankround#fzf#handler(yank_item) abort  " {{{
  let old_reg = [getreg('"'), getregtype('"')]
  let index = matchlist(a:yank_item, '\v^\s*(\d+)\t')[1]
  let [text, regtype] = yankround#_get_cache_and_regtype(index)
  call setreg('"', text, regtype)

  try
    execute 'normal! ""p'
  finally
    call setreg('"', old_reg[0], old_reg[1])
  endtry
endfunction  " }}}

function s:format_list_item(index) abort  " {{{
  let [text, _]  = yankround#_get_cache_and_regtype(a:index)

  " Avoid shell's syntax error in fzf's preview
  let text = substitute(text, "\n", "\\\\n", "g")

  return printf("%3d\t%s", a:index, text)
endfunction  " }}}
