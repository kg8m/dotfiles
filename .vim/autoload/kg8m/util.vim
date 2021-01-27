vim9script

final s:cache = {}

def kg8m#util#source_local_vimrc(): void  # {{{
  const filepath = expand("~/.vimrc.local")

  if filereadable(filepath)
    execute "source " .. filepath
  endif
enddef  # }}}

def kg8m#util#echo_error_msg(message: string): void  # {{{
  echohl ErrorMsg
  echomsg message
  echohl None
enddef  # }}}

def kg8m#util#echo_warn_msg(message: string): void  # {{{
  echohl WarningMsg
  echomsg message
  echohl None
enddef  # }}}

def kg8m#util#on_tmux(): bool  # {{{
  return !!exists("$TMUX")
enddef  # }}}

def kg8m#util#on_rails_dir(): bool  # {{{
  if has_key(s:cache, "on_rails_dir")
    return s:cache.on_rails_dir
  endif

  s:cache.on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return s:cache.on_rails_dir
enddef  # }}}

def kg8m#util#is_git_tmp_edit(): bool  # {{{
  return kg8m#util#is_git_commit() || kg8m#util#is_git_hunk_edit()
enddef  # }}}

def kg8m#util#is_git_commit(): bool  # {{{
  if has_key(s:cache, "is_git_commit")
    return s:cache.is_git_commit
  endif

  s:cache.is_git_commit = argc() ==# 1 && !!(argv()[0] =~# '\.git/COMMIT_EDITMSG$')
  return s:cache.is_git_commit
enddef  # }}}

def kg8m#util#is_git_hunk_edit(): bool  # {{{
  if has_key(s:cache, "is_git_hunk_edit")
    return s:cache.is_git_hunk_edit
  endif

  s:cache.is_git_hunk_edit = argc() ==# 1 && !!(argv()[0] =~# '\.git/addp-hunk-edit\.diff$')
  return s:cache.is_git_hunk_edit
enddef  # }}}

def kg8m#util#rubygems_path(): string  # {{{
  if has_key(s:cache, "rubygems_path")
    return s:cache.rubygems_path
  endif

  if exists("$RUBYGEMS_PATH")
    s:cache.rubygems_path = $RUBYGEMS_PATH
  else
    const command_prefix = (filereadable("./Gemfile") ? "bundle exec ruby" : "ruby -r rubygems")
    const command = command_prefix .. " -e 'print Gem.path.join(\"\\n\")'"
    const dirpaths = split(system(command), '\n')

    var rubygems_path = ""

    for dirpath in dirpaths
      if isdirectory(dirpath)
        rubygems_path = dirpath .. "/gems"
        break
      endif
    endfor

    if rubygems_path !=# ""
      s:cache.rubygems_path = rubygems_path
    else
      throw "Path to Ruby Gems not found. Candidates: " .. string(dirpaths)
    endif
  endif

  return s:cache.rubygems_path
enddef  # }}}

def kg8m#util#remote_copy(original_text: string): void  # {{{
  const text = original_text->substitute('\n$', "", "")->shellescape()

  system("printf %s " .. text .. " | ssh main -t 'LC_CTYPE=UTF-8 pbcopy'")

  if &columns > 50
    const less_space_text = substitute(text, '\v\n|\t', " ", "g")
    const truncated_text  = trim(kg8m#util#string_module().truncate(less_space_text, &columns - 30))
    echomsg "Copied: " .. truncated_text .. (trim(less_space_text) ==# truncated_text ? "" : "...")
  else
    echomsg "Copied"
  endif
enddef  # }}}

def kg8m#util#remove_trailing_whitespaces()  # {{{
  const position = getpos(".")
  keeppatterns '<,'>s/\s\+$//ge
  setpos(".", position)
enddef  # }}}

# Depend on vital.vim
def kg8m#util#string_module(): dict<func>  # {{{
  if has_key(s:cache, "string_module")
    return s:cache.string_module
  endif

  s:cache.string_module = vital#vital#import("Data.String")
  return s:cache.string_module
enddef  # }}}

# Depend on vital.vim
def kg8m#util#list_module(): dict<func>  # {{{
  if has_key(s:cache, "list_module")
    return s:cache.list_module
  endif

  s:cache.list_module = vital#vital#import("Data.List")
  return s:cache.list_module
enddef  # }}}

def kg8m#util#current_filename(): string  # {{{
  return expand("%:t")
enddef  # }}}

def kg8m#util#current_filepath(): string  # {{{
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->kg8m#util#formatted_filepath()
enddef  # }}}

def kg8m#util#current_relative_path(): string  # {{{
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->fnamemodify(":~:.")
enddef  # }}}

def kg8m#util#current_absolute_path(): string  # {{{
  const raw_filepath = expand("%")
  return empty(raw_filepath) ? "" : raw_filepath->fnamemodify(":~")
enddef  # }}}

def kg8m#util#formatted_filepath(filepath: string): string  # {{{
  if !has_key(s:cache, "regular_filepath_format")
    s:cache.regular_filepath_format = getcwd() ==# expand("~") ? ":~" : ":~:."
  endif

  return fnamemodify(filepath, s:cache.regular_filepath_format)
enddef  # }}}

def kg8m#util#japanese_matchpairs(): list<list<string>>  # {{{
  return [
    ["（", "）"],
    ["「", "」"],
    ["『", "』"],
    ["｛", "｝"],
    ["［", "］"],
    ["〈", "〉"],
    ["《", "》"],
    ["【", "】"],
    ["〔", "〕"],
    ["“", "”"],
    ["‘", "’"],
  ]
enddef  # }}}

def kg8m#util#filter_map(list: list<any>, Callback: func): list<any>  # {{{
  var result = []

  for item in list
    const new_item = Callback(item)

    if !!new_item
      result += [new_item]
    endif
  endfor

  return result
enddef  # }}}

def kg8m#util#convert_to_vim9script(): void  # {{{
  if getline(1) !=# "vim9script"
    append(0, "")
    append(0, "vim9script")
  endif

  # Replace `function` with `def` and remove `abort`
  :%s/\v^function>/def/Ie
  :%s/\v^endfunction>/enddef/Ie
  :%s/\v\) abort>/)/Ie

  # Remove `call` except for:
  #   - :call foo()
  #   - <Cmd>foo()
  #   - "call foo()"
  #   - 'call foo()'
  :%s/\v(:)@<!(\<Cmd\>)@<!(")@<!(')@<!<call\s+//Ie

  # Replace `let foo .= bar` with `let foo ..= bar`
  :%s/\v<(let\s+)([a-zA-Z&:_.]+)(\s+)\.\=/\1\2\3..=/Ie

  # Remove `let` except for:
  #   - :let foo = bar
  :%s/\v(:)@<!<let\s+//Ie

  # Remove function argument's prefix `a:`
  :%s/\v<a:([a-zA-Z_]+)/\1/gIe

  # Remove `#` from dictionary literals
  :%s/\v#\{/{/ge

  # Add white spaces around `..`
  :%s/\v([^.\/ ])\.\.%(\.)@!/\1 ../ge
  :%s/\v%(\.)@<!\.\.([^.\/ ])/.. \1/ge

  # Replace comment symbols `"` with `#`
  :%s/\v^(\s*)" /\1# /e
  :%s/\v" \{\{\{/# {{{/e
  :%s/\v" \}\}\}/# }}}/e

  # Remove line continuation symbols (`\`)
  :%s/\v^(\s*)\\ /\1/e

  # Reset some configurations
  set filetype=vim
enddef  # }}}
