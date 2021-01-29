vim9script

def kg8m#plugin#caw#configure(): void  # {{{
  map gc <Plug>(caw:hatpos:toggle)

  kg8m#plugin#configure({
    lazy:   true,
    on_map: [["nv", "<Plug>(caw:"]],
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef  # }}}

# Overwrite caw.vim's default: https://github.com/tyru/caw.vim/blob/41be34ca231c97d6be6c05e7ecb5b020f79cd37f/after/ftplugin/vim/caw.vim#L5-L9
def s:setup_vim(): void  # {{{
  b:caw_hatpos_sp  = " "
  b:caw_zeropos_sp = " "

  if getline(1) ==# "vim9script"
    b:caw_oneline_comment = "#"
  endif
enddef  # }}}

def s:on_source(): void  # {{{
  g:caw_no_default_keymappings = true
  g:caw_hatpos_skip_blank_line = true

  augroup my_vimrc  # {{{
    autocmd FileType Gemfile b:caw_oneline_comment = "#"

    # Re-setup lazily to overwrite caw.vim's defualt
    autocmd FileType vim s:setup_vim() | timer_start(100, () => s:setup_vim())
  augroup END  # }}}
enddef  # }}}

def s:on_post_source(): void  # {{{
  if &filetype ==# "vim"
    s:setup_vim()
  endif
enddef  # }}}
