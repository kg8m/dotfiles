vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"
import autoload "kg8m/util.vim"
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/logger.vim"

command! -nargs=1 -complete=customlist,Complete FzfRails Run(<q-args>)

export def EnterCommand(): void
  if !util.OnRailsDir()
    logger.Error("Not a Rails directory!!")
    return
  endif

  feedkeys(":FzfRails\<Space>", "t")
enddef

final specs: dict<dict<any>> = {}
final type_names = []

def Run(type: string): void
  const type_spec = specs[type]

  # `$FD_DEFAULT_OPTIONS` is always an empty string when evaluated in Vim because it is a array in shell.
  # So don’t evaluate it in Vim but evaluate it in shell.
  var command = ["fd", "${FD_DEFAULT_OPTIONS}", "${FD_EXTRA_OPTIONS}", "--full-path", "--type", "f", "--color", "always"]

  # Common excludes.
  command += ["--exclude", ".keep"]

  if has_key(type_spec, "dirs")
    command += listUtil.FilterMap(type_spec.dirs, (dir) => {
      return isdirectory(dir) ? $"--search-path={shellescape(dir)}" : false
    })
  endif

  if has_key(type_spec, "pattern")
    command += [shellescape(type_spec.pattern)]
  endif

  # Remove `./` for current directory.
  # Note: `fd`’s `--strip-cwd-prefix` option can’t be used with `--search-path` option(s).
  command += ["| sd '\\./' ''"]

  command += ["| sort_without_escape_sequences"]

  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    "source":  join(command, " "),
    "options": [
      "--prompt", $"Rails/{type}> ",
      "--preview", "preview {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  fzf#run(fzf#wrap("rails", options))
enddef

def Complete(arglead: string, _cmdline: string, _curpos: number): list<string>
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
      dirs: ["app/assets", "app/frontend", "app/javascript", "app/javascripts", "public"],
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
      dirs: [util.RubygemsPath()],
    },
    initializers: {
      dirs: ["config/initializers"],
    },
    javascripts: {
      dirs:    ["."],
      pattern: '\.(jsx?|tsx?|vue)(\.erb)?$',
    },
    lib: {
      dirs: ["lib"],
    },
    locales: {
      dirs: ["config/locales"],
    },
    public: {
      dirs: ["public"],
    },
    routing: {
      dirs:    ["config"],
      pattern: '/(routes\.rb|routes/.+\.rb)$',
    },
    sig: {
      dirs: ["sig"],
    },
    spec: {
      dirs: ["spec", "test"],
    },
    stylesheets: {
      dirs:    ["app", "public"],
      pattern: '\.(sass|s?css)$',
    },
    test: {
      dirs: ["spec", "test"],
    },
  })

  specs.css = specs.stylesheets
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

plugin.EnsureSourced("fzf.vim")
