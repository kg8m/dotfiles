vim9script

final cache = {}

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
  if has_key(cache, "on_rails_dir")
    return cache.on_rails_dir
  endif

  cache.on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return cache.on_rails_dir
enddef  # }}}

def kg8m#util#is_git_tmp_edit(): bool  # {{{
  return kg8m#util#is_git_commit() || kg8m#util#is_git_hunk_edit()
enddef  # }}}

def kg8m#util#is_git_commit(): bool  # {{{
  if has_key(cache, "is_git_commit")
    return cache.is_git_commit
  endif

  cache.is_git_commit = argc() ==# 1 && !!(argv()[0] =~# '\.git/COMMIT_EDITMSG$')
  return cache.is_git_commit
enddef  # }}}

def kg8m#util#is_git_hunk_edit(): bool  # {{{
  if has_key(cache, "is_git_hunk_edit")
    return cache.is_git_hunk_edit
  endif

  cache.is_git_hunk_edit = argc() ==# 1 && !!(argv()[0] =~# '\.git/addp-hunk-edit\.diff$')
  return cache.is_git_hunk_edit
enddef  # }}}

def kg8m#util#rubygems_path(): string  # {{{
  if has_key(cache, "rubygems_path")
    return cache.rubygems_path
  endif

  if exists("$RUBYGEMS_PATH")
    cache.rubygems_path = $RUBYGEMS_PATH
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
      cache.rubygems_path = rubygems_path
    else
      throw "Path to Ruby Gems not found. Candidates: " .. string(dirpaths)
    endif
  endif

  return cache.rubygems_path
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

# Depend on vital.vim
def kg8m#util#string_module(): dict<func>  # {{{
  if has_key(cache, "string_module")
    return cache.string_module
  endif

  cache.string_module = vital#vital#import("Data.String")
  return cache.string_module
enddef  # }}}

# Depend on vital.vim
def kg8m#util#list_module(): dict<func>  # {{{
  if has_key(cache, "list_module")
    return cache.list_module
  endif

  cache.list_module = vital#vital#import("Data.List")
  return cache.list_module
enddef  # }}}

def kg8m#util#current_filename(): string  # {{{
  return expand("%:t")
enddef  # }}}

def kg8m#util#current_relative_path(): string  # {{{
  return expand("%")->fnamemodify(":~:.")
enddef  # }}}

def kg8m#util#current_absolute_path(): string  # {{{
  return expand("%")->fnamemodify(":~")
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
