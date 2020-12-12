function kg8m#plugin#fzf#rails#run(type) abort  " {{{
  call s:setup()

  let type_spec = s:specs[a:type]

  if executable("gfind")
    let command = "gfind "..type_spec.dir.." -regextype posix-egrep"
  elseif has("mac")
    let command = "find -E "..type_spec.dir
  else
    let command = "find "..type_spec.dir.." -regextype posix-egrep"
  endif

  if has_key(type_spec, "pattern")
    let command .= " \\( -regex '"..type_spec.pattern.."' \\)"
  endif

  if has_key(type_spec, "excludes")
    let excludes = join(type_spec.excludes, " -not ")
    let command .= " \\( -not "..excludes.." \\)"
  endif

  let command .= " -type f -not -name '.keep'"
  let command .= " | sort"

  let options = {
  \   "source":  command,
  \   "options": [
  \     "--prompt", "Rails/"..a:type.."> ",
  \     "--preview", "git cat {}",
  \     "--preview-window", "right:50%:wrap:nohidden",
  \   ],
  \ }

  call fzf#run(fzf#wrap("rails", options))
endfunction  " }}}

" For command's '-complete' option
function kg8m#plugin#fzf#rails#type_names(arglead, cmdline, curpos) abort  " {{{
  call s:setup()

  if !has_key(s:, "type_names")
    let s:type_names = s:specs->keys()->sort()
  endif

  if a:arglead ==# ""
    return s:type_names
  else
    return filter(
    \   copy(s:type_names),
    \   { _, name -> name =~# "^"..a:arglead }
    \ )
  endif
endfunction  " }}}

function s:setup() abort  " {{{
  if has_key(s:, "specs")
    return
  endif

  let s:specs = #{
  \   assets: #{
  \     dir:      "{app/assets,app/javascripts,public}",
  \     excludes: ["-path 'public/packs*'"],
  \   },
  \   config: #{
  \     dir: "config",
  \   },
  \   gems: #{
  \     dir: kg8m#util#rubygems_path(),
  \   },
  \   initializers: #{
  \     dir: "config/initializers",
  \   },
  \   javascripts: #{
  \     dir:      "{app,public}",
  \     pattern:  '.*\.(jsx?|tsx?|vue)$',
  \     excludes: ["-path 'public/packs*'"],
  \   },
  \   lib: #{
  \     dir: "lib",
  \   },
  \   locales: #{
  \     dir: "config/locales",
  \   },
  \   public: #{
  \     dir:      "public",
  \     excludes: ["-path 'public/packs*'"],
  \   },
  \   script: #{
  \     dir: "script",
  \   },
  \   spec: #{
  \     dir: "{spec,test}",
  \   },
  \   stylesheets: #{
  \     dir:      "{app,public}",
  \     pattern:  '.*\.(sass|s?css)$',
  \     excludes: ["-path 'public/packs*'"],
  \   },
  \   test: #{
  \     dir: "{spec,test}",
  \   },
  \ }

  let s:specs["db/migrates"] = #{ dir: "db/migrate" }

  for app_dir in globpath("app", "*", 0, 1)
    if isdirectory(app_dir)
      let s:specs[app_dir] = #{ dir: app_dir }

      " e.g., `app/controllers` => `controllers`
      let alternative = fnamemodify(app_dir, ":t")

      if !has_key(s:specs, alternative)
        let s:specs[alternative] = #{ dir: app_dir }
      endif
    endif
  endfor

  for test_dir in globpath("spec,test", "*", 0, 1)
    if isdirectory(test_dir)
      let s:specs[test_dir] = #{ dir: test_dir }

      " e.g., `test/fixtures` => `fixtures_test`
      let alternative = join(reverse(split(test_dir, "/")), "_")
      let s:specs[alternative] = #{ dir: test_dir }
    endif
  endfor

  if has_key(g:, "fzf#rails#extra_specs")
    for name in keys(g:fzf#rails#extra_specs)
      if has_key(s:specs, name)
        call extend(
        \   s:specs[name],
        \   g:fzf#rails#extra_specs[name]
        \ )
      else
        let s:specs[name] = g:fzf#rails#extra_specs[name]
      endif
    endfor
  endif

  if has_key(g:, "fzf#rails#specs_formatters")
    for Formatter in g:fzf#rails#specs_formatters
      call Formatter(s:specs)
    endfor
  endif
endfunction  " }}}
