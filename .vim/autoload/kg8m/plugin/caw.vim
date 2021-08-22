vim9script

def kg8m#plugin#caw#configure(): void
  map <expr> gc <SID>exec_with_setup()

  kg8m#plugin#configure({
    lazy: true,
    hook_source: () => s:on_source(),
  })
enddef

def s:exec_with_setup(): string
  if !kg8m#plugin#is_sourced("caw.vim")
    kg8m#plugin#source("caw.vim")
  endif

  s:setup_filetype()
  return "\<Plug>(caw:hatpos:toggle)"
enddef

def s:setup_filetype(): void
  if &filetype ==# "Gemfile"
    s:setup_gemfile()
  elseif &filetype ==# "vim"
    s:setup_vim()
  endif
enddef

def s:setup_gemfile(): void
  caw#load_ftplugin("ruby")
enddef

# Overwrite caw.vim's default: https://github.com/tyru/caw.vim/blob/41be34ca231c97d6be6c05e7ecb5b020f79cd37f/after/ftplugin/vim/caw.vim#L5-L9
def s:setup_vim(): void
  b:caw_hatpos_sp  = " "
  b:caw_zeropos_sp = " "

  if getline(1) ==# "vim9script"
    b:caw_oneline_comment = "#"
  endif
enddef

def s:on_source(): void
  g:caw_no_default_keymappings = true
  g:caw_hatpos_skip_blank_line = true
enddef
