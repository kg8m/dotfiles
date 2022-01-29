vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

command! -nargs=1 -complete=customlist,kg8m#plugin#fzf#rails#complete FzfRails kg8m#plugin#fzf#rails#run(<q-args>)

def kg8m#plugin#fzf#rails#enter_command(): void
  feedkeys(":FzfRails\<Space>", "t")
enddef

final s:specs: dict<dict<any>> = {}
final s:type_names = []

def kg8m#plugin#fzf#rails#run(type: string): void
  const type_spec = s:specs[type]

  var command = ["fd", "--hidden", "--no-ignore", "--full-path", "--type=f", "--color=always"]

  # Sort results.
  command += ["--threads=1"]

  # Common excludes.
  command += ["--exclude='.keep'"]

  if has_key(type_spec, "dirs")
    command += mapnew(type_spec.dirs, (_, dir) => printf("--search-path=%s", shellescape(dir)))
  endif

  if has_key(type_spec, "excludes")
    command += mapnew(type_spec.excludes, (_, exclude) => printf("--exclude=%s", shellescape(exclude)))
  endif

  if has_key(type_spec, "pattern")
    command += [shellescape(type_spec.pattern)]
  endif

  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    "source":  join(command, " "),
    "options": [
      "--prompt", "Rails/" .. type .. "> ",
      "--preview", "preview {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("rails", options)))
enddef

def kg8m#plugin#fzf#rails#complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  if arglead ==# ""
    return s:type_names
  else
    return s:type_names
      ->copy()
      ->filter((_, type_name) => type_name =~# "^" .. arglead)
  endif
enddef

def s:setup(): void
  extend(s:specs, {
    assets: {
      dirs:     ["app/assets", "app/javascripts", "public"],
      excludes: ["public/packs*"],
    },
    config: {
      dirs: ["config"],
    },
    environments: {
      dirs:    ["config"],
      pattern: '(/environment\.rb|/environments/.+\.rb)$',
    },
    gems: {
      dirs: [kg8m#util#rubygems_path()],
    },
    initializers: {
      dirs: ["config/initializers"],
    },
    javascripts: {
      dirs:     ["app", "public"],
      pattern:  '\.(jsx?|tsx?|vue)$',
      excludes: ["public/packs*"],
    },
    lib: {
      dirs: ["lib"],
    },
    locales: {
      dirs: ["config/locales"],
    },
    public: {
      dirs:     ["public"],
      excludes: ["public/packs*"],
    },
    routing: {
      dirs:    ["config"],
      pattern: '/(routes\.rb|routes/.+\.rb)$',
    },
    script: {
      dirs: ["script"],
    },
    spec: {
      dirs: ["spec", "test"],
    },
    stylesheets: {
      dirs:     ["app", "public"],
      pattern:  '\.(sass|s?css)$',
      excludes: ["public/packs*"],
    },
    test: {
      dirs: ["spec", "test"],
    },
  })

  s:specs["db/migrates"] = { dirs: ["db/migrate"] }

  for app_dir in globpath("app", "*", 0, 1)
    if isdirectory(app_dir)
      s:specs[app_dir] = { dirs: [app_dir] }

      # e.g., `app/controllers` => `controllers`
      const alternative = fnamemodify(app_dir, ":t")

      if !has_key(s:specs, alternative)
        s:specs[alternative] = { dirs: [app_dir] }
      endif
    endif
  endfor

  for test_dir in globpath("spec,test", "*", 0, 1)
    if isdirectory(test_dir)
      s:specs[test_dir] = { dirs: [test_dir] }

      # e.g., `test/fixtures` => `fixtures-of-test`
      const alternative = join(reverse(split(test_dir, "/")), "-of-")
      s:specs[alternative] = { dirs: [test_dir] }
    endif
  endfor

  if has_key(g:, "fzf#rails#extra_specs")
    for name in keys(g:fzf#rails#extra_specs)
      if has_key(s:specs, name)
        extend(
          s:specs[name],
          g:fzf#rails#extra_specs[name]
        )
      else
        s:specs[name] = g:fzf#rails#extra_specs[name]
      endif
    endfor
  endif

  if has_key(g:, "fzf#rails#specs_formatters")
    for Formatter in g:fzf#rails#specs_formatters
      Formatter(s:specs)
    endfor
  endif

  extend(s:type_names, s:specs->keys()->sort())
enddef
s:setup()
