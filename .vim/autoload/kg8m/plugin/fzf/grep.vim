vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Respect `$RIPGREP_EXTRA_OPTIONS` (Fzf's `:Rg` doesn't respect it)
def kg8m#plugin#fzf#grep#run(pattern: string, path: string = ""): void
  if empty(pattern)
    echo "Canceled."
    return
  endif

  const escaped_pattern = shellescape(pattern)
  const escaped_path    = empty(path) ? "" : shellescape(path)
  const grep_args       = escaped_pattern .. " " .. escaped_path
  const grep_options    = s:options()

  final fzf_options = [
    "--header", "Grep: " .. grep_args,
    "--delimiter", ":",
  ]

  var preview_option        = kg8m#plugin#get_info("fzf.vim").path .. "/bin/preview.sh "
  var preview_window_option = "down:75%:wrap:nohidden:"

  if filereadable(path)
    preview_option        ..= escaped_path .. ":{}"
    preview_window_option ..= "+{1}-/2"
  else
    preview_option        ..= "{}"
    preview_window_option ..= "+{2}-/2"
  endif

  extend(fzf_options, [
    "--preview", preview_option,
    "--preview-window", preview_window_option,
  ])

  fzf#vim#grep("rg " .. grep_options .. " " .. grep_args, true, { options: fzf_options })
enddef

def kg8m#plugin#fzf#grep#expr(options = {}): string
  final args = [string(s:input_pattern())]

  if get(options, "path")
    add(args, string(s:input_path()))
  endif

  return ":call kg8m#plugin#fzf#grep#run(" .. join(args, ", ") .. ")\<CR>"
enddef

def s:input_pattern(): string
  var preset: string

  if mode() =~? 'v'
    feedkeys('"gy', "x")
    preset = @"
  else
    preset = ""
  endif

  return input("FzfGrep Pattern: ", preset, "tag")
enddef

def s:input_path(): string
  const path = input("FzfGrep Path: ", "", "file")->expand()

  if empty(path)
    echoerr "Path not specified."
  elseif !isdirectory(path) && !filereadable(path)
    echoerr "Path doesn't exist."
  endif

  return path
enddef

def s:options(): string
  const base = "--column --line-number --no-heading --color=always"

  if empty($RIPGREP_EXTRA_OPTIONS)
    return base
  else
    final splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
    const escaped  = map(splitted, (_, option) => shellescape(option))
    return base .. " " .. join(escaped, " ")
  endif
enddef
