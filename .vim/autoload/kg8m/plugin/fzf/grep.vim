vim9script

final cache = {}

kg8m#plugin#EnsureSourced("fzf.vim")

# Respect `$RIPGREP_EXTRA_OPTIONS` (fzf's `:Rg` doesn't respect it)
command! -nargs=+ -complete=customlist,kg8m#plugin#fzf#grep#complete FzfGrep kg8m#plugin#fzf#grep#Run(<q-args>)

export def EnterCommand(preset: string = ""): void
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
  feedkeys(":\<C-u>FzfGrep\<Space>'" .. preset .. "'\<Left>", "t")
enddef

export def Run(args: string): void
  const grep_command = ["rg", GrepFullOptions(), args]->join(" ")
  const has_column   = true
  const fzf_options  = [
    "--header",         JoinPresences(["Grep:", GrepExplicitOptions(), args]),
    "--delimiter",      ":",
    "--preview",        "preview {}",
    "--preview-window", "down:75%:wrap:nohidden:+{2}-/2",
  ]

  kg8m#plugin#fzf#Run(() => fzf#vim#grep(grep_command, has_column, { options: fzf_options }))
enddef

export def Complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  if empty(arglead) || arglead =~# '^-'
    if !has_key(cache, "grep_option_candidates")
      cache.grep_option_candidates = system(CommandToShowGrepOptionCandidates())->split("\n")
    endif

    const pattern = "^" .. arglead
    return cache.grep_option_candidates->copy()->filter((_, item) => item =~# pattern)
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
    return getcompletion(pattern, "file")->map((_, item) => prefix .. item)
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
    final splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
    const escaped  = map(splitted, (_, option) => shellescape(option))

    cache.grep_explicit_options = join(escaped, " ")
  endif

  return cache.grep_explicit_options
enddef

def CommandToShowGrepOptionCandidates(): string
  const show_help           = "rg --help"
  const filter_option_lines = "grep -E '^\\s*-'"
  const extract_options     = "grep -E '\\-[.0-9a-zA-Z]\\b|--[-0-9a-zA-Z]+' -o"
  const sort_and_uniquify   = "sort -u"

  return [show_help, filter_option_lines, extract_options, sort_and_uniquify]->join(" | ")
enddef

def JoinPresences(list: list<string>): string
  const Mapper = (item) => empty(item) ? false : item
  return list->kg8m#util#list#FilterMap(Mapper)->join(" ")
enddef
