vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

final s:specs: dict<dict<any>> = {}
final s:type_names = []

var s:is_specs_initialized = false
var s:is_type_names_initialized = false

def kg8m#plugin#fzf#rails#run(type: string): void
  s:setup()

  const type_spec = s:specs[type]

  var command: string

  if executable("gfind")
    command = "gfind " .. type_spec.dir .. " -regextype posix-egrep"
  elseif has("mac")
    command = "find -E " .. type_spec.dir
  else
    command = "find " .. type_spec.dir .. " -regextype posix-egrep"
  endif

  if has_key(type_spec, "pattern")
    command ..= " \\( -regex '" .. type_spec.pattern .. "' \\)"
  endif

  if has_key(type_spec, "excludes")
    const excludes = join(type_spec.excludes, " -not ")
    command ..= " \\( -not " .. excludes .. " \\)"
  endif

  command ..= " -type f -not -name '.keep'"
  command ..= " | sort"

  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    "source":  command,
    "options": [
      "--prompt", "Rails/" .. type .. "> ",
      "--preview", "git cat {}",
      "--preview-window", "down:75%:wrap:nohidden",
    ],
  }

  fzf#run(fzf#wrap("rails", options))
enddef

# For command's '-complete' option
def kg8m#plugin#fzf#rails#type_names(arglead: string, _cmdline: string, _curpos: number): list<string>
  s:setup()

  if !s:is_type_names_initialized
    extend(s:type_names, s:specs->keys()->sort())
    s:is_type_names_initialized = true
  endif

  if arglead ==# ""
    return s:type_names
  else
    return s:type_names
      ->copy()
      ->filter((_, type_name) => type_name =~# "^" .. arglead)
  endif
enddef

def s:setup(): void
  if s:is_specs_initialized
    return
  endif

  extend(s:specs, {
    assets: {
      dir:      "{app/assets,app/javascripts,public}",
      excludes: ["-path 'public/packs*'"],
    },
    config: {
      dir: "config",
    },
    gems: {
      dir: kg8m#util#rubygems_path(),
    },
    initializers: {
      dir: "config/initializers",
    },
    javascripts: {
      dir:      "{app,public}",
      pattern:  '.*\.(jsx?|tsx?|vue)$',
      excludes: ["-path 'public/packs*'"],
    },
    lib: {
      dir: "lib",
    },
    locales: {
      dir: "config/locales",
    },
    public: {
      dir:      "public",
      excludes: ["-path 'public/packs*'"],
    },
    routing: {
      dir: "config",
      pattern:  '.*/(routes\.rb|routes/.*\.rb)$',
    },
    script: {
      dir: "script",
    },
    spec: {
      dir: "{spec,test}",
    },
    stylesheets: {
      dir:      "{app,public}",
      pattern:  '.*\.(sass|s?css)$',
      excludes: ["-path 'public/packs*'"],
    },
    test: {
      dir: "{spec,test}",
    },
  })

  s:specs["db/migrates"] = { dir: "db/migrate" }

  for app_dir in globpath("app", "*", 0, 1)
    if isdirectory(app_dir)
      s:specs[app_dir] = { dir: app_dir }

      # e.g., `app/controllers` => `controllers`
      const alternative = fnamemodify(app_dir, ":t")

      if !has_key(s:specs, alternative)
        s:specs[alternative] = { dir: app_dir }
      endif
    endif
  endfor

  for test_dir in globpath("spec,test", "*", 0, 1)
    if isdirectory(test_dir)
      s:specs[test_dir] = { dir: test_dir }

      # e.g., `test/fixtures` => `fixtures_test`
      const alternative = join(reverse(split(test_dir, "/")), "_")
      s:specs[alternative] = { dir: test_dir }
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

  s:is_specs_initialized = true
enddef
