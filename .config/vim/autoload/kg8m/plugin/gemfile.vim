vim9script

export def Configure(): void
  augroup vimrc-plugin-gemfile
    autocmd!

    # Execute lazily for overwriting default configs.
    autocmd FileType Gemfile timer_start(100, (_) => SetupBuffer())
  augroup END
enddef

def SetupBuffer(): void
  runtime! ftplugin/ruby.vim indent/ruby.vim
enddef
