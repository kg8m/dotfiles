vim9script

def kg8m#plugin#ruby#configure(): void  # {{{
  g:no_ruby_maps = v:true

  augroup my_vimrc  # {{{
    # vim-ruby overwrites vim-gemfile's filetype detection
    autocmd BufEnter Gemfile set filetype=Gemfile

    # Prevent vim-matchup from being wrong for Ruby's modifier `if`/`unless`
    autocmd FileType ruby unlet! b:ruby_no_expensive
  augroup END  # }}}
enddef  # }}}
