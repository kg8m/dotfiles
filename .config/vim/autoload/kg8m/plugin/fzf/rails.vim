vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

command! -nargs=1 -complete=customlist,kg8m#plugin#fzf#rails#Complete FzfRails kg8m#plugin#fzf#rails#Run(<q-args>)

export def EnterCommand(): void
  feedkeys(":FzfRails\<Space>", "t")
enddef

final specs: dict<dict<any>> = {}
final type_names = []

export def Run(type: string): void
  const type_spec = specs[type]

  var command = ["fd", $FD_DEFAULT_OPTIONS, "--full-path", "--type", "f", "--color", "always"]

  # Common excludes.
  command += ["--exclude='.keep'"]

  if has_key(type_spec, "dirs")
    command += mapnew(type_spec.dirs, (_, dir) => $"--search-path={shellescape(dir)}")
  endif

  if has_key(type_spec, "excludes")
    command += mapnew(type_spec.excludes, (_, exclude) => $"--exclude={shellescape(exclude)}")
  endif

  if has_key(type_spec, "pattern")
    command += [shellescape(type_spec.pattern)]
  endif

  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    "source":  join(command, " "),
    "options": [
      "--prompt", $"Rails/{type}> ",
      "--preview", "preview {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("rails", options)))
enddef

export def Complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  if arglead ==# ""
    return type_names
  else
    return type_names
      ->copy()
      ->filter((_, type_name) => type_name =~# $"^{arglead}")
  endif
enddef

def Setup(): void
  extend(specs, {
    assets: {
      dirs:     ["app/assets", "app/javascripts", "public"],
      excludes: ["public/packs*"],
    },
    config: {
      dirs: ["config"],
    },
    db: {
      dirs: ["db"],
    },
    environments: {
      dirs:    ["config"],
      pattern: '(/environment\.rb|/environments/.+\.rb)$',
    },
    gems: {
      dirs: [kg8m#util#RubygemsPath()],
    },
    initializers: {
      dirs: ["config/initializers"],
    },
    javascripts: {
      dirs:     ["app", "public"],
      pattern:  '\.(jsx?|tsx?|vue)(\.erb)?$',
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

  specs.js = specs.javascripts

  for app_dir in globpath("app", "*", 0, 1)
    if isdirectory(app_dir)
      # e.g., `app/controllers` => `controllers`
      const name = fnamemodify(app_dir, ":t")

      # Skip singular name if its plural name is already defined.
      if has_key(specs, $"{name}s")
        continue
      endif

      if !has_key(specs, name)
        specs[name] = { dirs: [app_dir] }
      endif
    endif
  endfor

  for test_dir in globpath("spec,test", "*", 0, 1)
    if isdirectory(test_dir)
      if !has_key(specs, test_dir)
        specs[test_dir] = { dirs: [test_dir] }
      endif

      # e.g., `test/fixtures` => `fixtures-of-test`
      const alternative = join(reverse(split(test_dir, "/")), "-of-")

      if !has_key(specs, alternative)
        specs[alternative] = { dirs: [test_dir] }
      endif
    endif
  endfor

  if has_key(g:, "fzf#rails#extra_specs")
    for name in keys(g:fzf#rails#extra_specs)
      if has_key(specs, name)
        extend(
          specs[name],
          g:fzf#rails#extra_specs[name]
        )
      else
        specs[name] = g:fzf#rails#extra_specs[name]
      endif
    endfor
  endif

  if has_key(g:, "fzf#rails#specs_formatters")
    for Formatter in g:fzf#rails#specs_formatters
      Formatter(specs)
    endfor
  endif

  extend(type_names, specs->keys()->sort())
enddef
Setup()
