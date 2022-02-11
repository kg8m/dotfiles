vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_start: true,
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

def OnSource(): void
  g:parallel_auto_ctags#entry_points = {
    pwd: {
      path:    ".",
      options: ["--languages=Go,JavaScript,Make,Ruby,Sh,TypeScript,Vim,Yaml"],
      events:  ["VimEnter", "BufWritePost"],
      silent:  false,
    },
  }

  if kg8m#util#OnRailsDir()
    &tags ..= "," .. kg8m#util#RubygemsPath() .. "/../tags"

    g:parallel_auto_ctags#entry_points.gems = {
      path:    kg8m#util#RubygemsPath() .. "/..",
      options: ["--exclude=test", "--exclude=spec", "--languages=Ruby"],
      events:  ["VimEnter"],
      silent:  false,
    }
  endif
enddef

def OnPostSource(): void
  parallel_auto_ctags#create_all()
enddef
