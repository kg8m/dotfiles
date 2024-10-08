vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"
import autoload "kg8m/util/grep.vim" as grepUtil
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/qf.vim" as qfUtil
import autoload "kg8m/util/string.vim" as stringUtil

final cache = {}

# Respect `$RIPGREP_EXTRA_OPTIONS` (fzf’s `:Rg` doesn’t respect it)
command! -nargs=+ -complete=customlist,Complete FzfGrep Run(<q-args>)

export def EnterCommand(preset: string = "", options = {}): void
  const escaped_preset =
    escape(preset, ".?*+^$()[]{}\\")
      ->substitute('^-', '\\-', "")
      ->substitute("'", "'\\\\''", "g")
  const preset_prefix = get(options, "word_boundary", false) && preset =~# '^\w' ? '\b' : ""
  const preset_suffix = get(options, "word_boundary", false) && preset =~# '\w$' ? '\b' : ""

  const hint =<< trim HINT
    Hint:
      - :FzfGrep '{PATTERN}'                        # Search the current directory
      - :FzfGrep '{PATTERN}' {PATH_TO_SEARCH}       # Search specified files/directories
      - :FzfGrep '{PATTERN}' -g !{PATH_TO_EXCLUDE}  # Exclude files/directories for sarching (--glob)
      - :FzfGrep '{PATTERN}' -s                     # Search case sensitively (--case-sensitive)
      - :FzfGrep '{PATTERN}' -o                     # Print only the matched parts of a matching line (--only-matching)
      - :FzfGrep '{PATTERN}' -v                     # Invert matching (--invert-match)
      - :FzfGrep '{PATTERN}' -E {ENCODING}          # Specify the text encoding, e.g., shift-jis (--encoding)
  HINT

  echo hint->join("\n") .. "\n\n"
  feedkeys($":\<C-u>FzfGrep\<Space>'{preset_prefix}{escaped_preset}{preset_suffix}'\<Left>", "t")
enddef

def Run(args: string): void
  const grep_command = ["rg", GrepFullOptions(), args]->join(" ")
  const fzf_options  = [
    "--header",         JoinPresences(["Grep:", GrepExplicitOptions(), args]),
    "--delimiter",      ":",
    "--preview",        "preview {}",
    "--preview-window", "down:75%:wrap:nohidden:+{2}-/2",
  ]

  fzf#vim#grep(grep_command, { options: fzf_options, "sink*": BuildHandler(args) })
enddef

def Complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  if empty(arglead) || stringUtil.StartsWith(arglead, "-")
    if !has_key(cache, "grep_option_candidates")
      cache.grep_option_candidates = system(CommandToShowGrepOptionCandidates())->split("\n")
    endif

    const pattern = $"^{arglead}"
    return cache.grep_option_candidates->copy()->filter((_, item) => item =~# pattern)
  elseif stringUtil.StartsWith(arglead, "$")
    const pattern = arglead[1 : -1]
    const envvar_names = getcompletion(pattern, "environment")

    if empty(envvar_names)
      return getcompletion(arglead, "file")
    else
      const prefix = "$"
      return envvar_names->mapnew((_, item) => $"{prefix}{item}")
    endif
  else
    var pattern = arglead

    if pattern =~# '^["'']'
      pattern = pattern[1 :]
    endif

    if pattern =~# '^\'
      pattern = pattern[1 :]
    endif

    if pattern =~# '^!'
      pattern = pattern[1 :]
    endif

    const prefix = strpart(arglead, 0, len(arglead) - len(pattern))
    return getcompletion(pattern, "file")->map((_, item) => $"{prefix}{item}")
  endif
enddef

def GrepFullOptions(): string
  return JoinPresences([GrepImplicitOptions(), GrepExplicitOptions()])
enddef

def GrepImplicitOptions(): string
  return "--column --line-number --no-heading --with-filename --color always"
enddef

def GrepExplicitOptions(): string
  if has_key(cache, "grep_explicit_options")
    return cache.grep_explicit_options
  endif

  if empty($RIPGREP_EXTRA_OPTIONS)
    cache.grep_explicit_options = ""
  else
    final split   = split($RIPGREP_EXTRA_OPTIONS, " ")
    const escaped = map(split, (_, option) => shellescape(option))

    cache.grep_explicit_options = join(escaped, " ")
  endif

  return cache.grep_explicit_options
enddef

def CommandToShowGrepOptionCandidates(): string
  const show_help           = "rg --help"
  const filter_option_lines = "rg '^\\s*-'"
  const extract_options     = "rg '\\-[.0-9a-zA-Z]\\b|--[-0-9a-zA-Z]+' -o"
  const sort_and_uniquify   = "sort -u"

  return [show_help, filter_option_lines, extract_options, sort_and_uniquify]->join(" | ")
enddef

def JoinPresences(list: list<string>): string
  const Mapper = (item) => empty(item) ? false : item
  return list->listUtil.FilterMap(Mapper)->join(" ")
enddef

def BuildHandler(args: string): func(list<string>): void
  const query = matchstr(args, '\v^[''"]\zs.{-}\ze[''"]%($|\s)')
  return (lines: list<string>) => {
    grepUtil.BuildQflistFromLines(query, lines[1 :], (qfcontents) => {
      qfUtil.GoToContent(qfcontents[0])
    })
  }
enddef

plugin.EnsureSourced("fzf.vim")
