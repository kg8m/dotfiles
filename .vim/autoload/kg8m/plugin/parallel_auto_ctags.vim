vim9script

def kg8m#plugin#parallel_auto_ctags#configure(): void
  g:parallel_auto_ctags#entry_points = {
    pwd: {
      path:    ".",
      options: ["--languages=Go,JavaScript,Make,Ruby,Sh,TypeScript,Vim,Yaml"],
      events:  ["VimEnter", "BufWritePost"],
      silent:  false,
    },
  }

  if kg8m#util#on_rails_dir()
    &tags ..= "," .. kg8m#util#rubygems_path() .. "/../tags"

    g:parallel_auto_ctags#entry_points.gems = {
      path:    kg8m#util#rubygems_path() .. "/..",
      options: ["--exclude=test", "--exclude=spec", "--languages=Ruby"],
      events:  ["VimEnter"],
      silent:  false,
    }
  endif
enddef
