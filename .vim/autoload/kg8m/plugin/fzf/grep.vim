vim9script

final s:cache = {}

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Respect `$RIPGREP_EXTRA_OPTIONS` (Fzf's `:Rg` doesn't respect it)
command! -nargs=+ -complete=customlist,kg8m#plugin#fzf#grep#complete FzfGrep kg8m#plugin#fzf#grep#run(<q-args>)

def kg8m#plugin#fzf#grep#enter_command(preset: string = ""): void
  const hint =<< trim HINT
    Hint:
      - :FzfGrep '{PATTERN}'                        # Search the current directory
      - :FzfGrep '{PATTERN}' {PATH_TO_SEARCH}       # Search specified files/directories
      - :FzfGrep '{PATTERN}' -g !{PATH_TO_EXCLUDE}  # Exclude files/directories for sarching (--glob)
      - :FzfGrep '{PATTERN}' -s                     # Search case sensitively (--case-sensitive)
      - :FzfGrep '{PATTERN}' -o                     # Print only the matched parts of a matching line (--only-matching)
      - :FzfGrep '{PATTERN}' -v                     # Invert matching (--invert-match)
  HINT

  echo hint->join("\n") .. "\n\n"
  feedkeys(":\<C-u>FzfGrep\<Space>'" .. preset .. "'\<Left>", "t")
enddef

def kg8m#plugin#fzf#grep#run(args: string): void
  const grep_command = ["rg", s:grep_full_options(), args]->join(" ")
  const has_column   = true
  const fzf_options  = [
    "--header",         s:join_presences(["Grep:", s:grep_explicit_options(), args]),
    "--delimiter",      ":",
    "--preview",        kg8m#plugin#get_info("fzf.vim").path .. "/bin/preview.sh {}",
    "--preview-window", "down:75%:wrap:nohidden:+{2}-/2",
  ]

  fzf#vim#grep(grep_command, has_column, { options: fzf_options })
enddef

def kg8m#plugin#fzf#grep#complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  if empty(arglead)
    return []
  endif

  if arglead =~# '^-'
    if !has_key(s:cache, "grep_option_candidates")
      s:cache.grep_option_candidates = system(s:command_to_show_grep_option_candidates())->split("\n")
    endif

    const pattern = "^" .. arglead
    return s:cache.grep_option_candidates->copy()->filter((_, item) => item =~# pattern)
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

def s:grep_full_options(): string
  return s:join_presences([s:grep_implicit_options(), s:grep_explicit_options()])
enddef

def s:grep_implicit_options(): string
  return "--column --line-number --no-heading --with-filename --color always"
enddef

def s:grep_explicit_options(): string
  if has_key(s:cache, "grep_explicit_options")
    return s:cache.grep_explicit_options
  endif

  if empty($RIPGREP_EXTRA_OPTIONS)
    s:cache.grep_explicit_options = ""
  else
    final splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
    const escaped  = map(splitted, (_, option) => shellescape(option))

    s:cache.grep_explicit_options = join(escaped, " ")
  endif

  return s:cache.grep_explicit_options
enddef

def s:command_to_show_grep_option_candidates(): string
  const show_help           = "rg --help"
  const filter_option_lines = "grep -E '^\\s*-'"
  const extract_options     = "grep -E '\\-[.0-9a-zA-Z]\\b|--[-0-9a-zA-Z]+' -o"
  const sort_and_uniquify   = "sort -u"

  return [show_help, filter_option_lines, extract_options, sort_and_uniquify]->join(" | ")
enddef

def s:join_presences(list: list<string>): string
  const Mapper = (item) => empty(item) ? false : item
  return list->kg8m#util#list#filter_map(Mapper)->join(" ")
enddef
