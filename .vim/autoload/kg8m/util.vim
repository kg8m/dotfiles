function! kg8m#util#echo_error_msg(message) abort  " {{{
  echohl ErrorMsg
  echomsg a:message
  echohl None
endfunction  " }}}

function! kg8m#util#on_tmux() abort  " {{{
  return exists("$TMUX")
endfunction  " }}}

function! kg8m#util#on_rails_dir() abort  " {{{
  if has_key(s:, "on_rails_dir")
    return s:on_rails_dir
  endif

  let s:on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return s:on_rails_dir
endfunction  " }}}

function! kg8m#util#is_git_tmp_edit() abort  " {{{
  return kg8m#util#is_git_commit() || kg8m#util#is_git_hunk_edit()
endfunction  " }}}

function! kg8m#util#is_git_commit() abort  " {{{
  if has_key(s:, "is_git_commit")
    return s:is_git_commit
  endif

  let s:is_git_commit = argc() ==# 1 && argv()[0] =~# '\.git/COMMIT_EDITMSG$'
  return s:is_git_commit
endfunction  " }}}

function! kg8m#util#is_git_hunk_edit() abort  " {{{
  if has_key(s:, "is_git_hunk_edit")
    return s:is_git_hunk_edit
  endif

  let s:is_git_hunk_edit = argc() ==# 1 && argv()[0] =~# '\.git/addp-hunk-edit\.diff$'
  return s:is_git_hunk_edit
endfunction  " }}}

function! kg8m#util#rubygems_path() abort  " {{{
  if has_key(s:, "rubygems_path")
    return s:rubygems_path
  endif

  if exists("$RUBYGEMS_PATH")
    let s:rubygems_path = $RUBYGEMS_PATH
  else
    let command_prefix = (filereadable("./Gemfile") ? "bundle exec ruby" : "ruby -r rubygems")
    let command = command_prefix.." -e 'print Gem.path.join(\"\\n\")'"
    let dirpaths = split(system(command), '\n')

    for dirpath in dirpaths
      if isdirectory(dirpath)
        let rubygems_path = dirpath.."/gems"
        break
      endif
    endfor

    if exists("rubygems_path")
      let s:rubygems_path = rubygems_path
    else
      throw "Path to Ruby Gems not found. Candidates: "..string(dirpaths)
    endif
  endif

  return s:rubygems_path
endfunction  " }}}

function! kg8m#util#remote_copy(text) abort  " {{{
  let text = a:text
  let text = substitute(text, '\n$', "", "")
  let text = shellescape(text)

  call system("printf %s "..text.." | ssh main -t 'LC_CTYPE=UTF-6 pbcopy'")

  if &columns > 50
    let text = substitute(text, '\v\n|\t', " ", "g")
    let truncated = trim(kg8m#util#string_module().truncate(text, &columns - 30))
    echomsg "Copied: "..truncated..(trim(text) ==# truncated ? "" : "...")
  else
    echomsg "Copied"
  endif
endfunction  " }}}

" Depend on vital.vim
function! kg8m#util#string_module() abort  " {{{
  if !has_key(s:, "string_module")
    let s:string_module = vital#vital#import("Data.String")
  endif

  return s:string_module
endfunction  " }}}

" Depend on vital.vim
function! kg8m#util#list_module() abort  " {{{
  if !has_key(s:, "list_module")
    let s:list_module = vital#vital#import("Data.List")
  endif

  return s:list_module
endfunction  " }}}

function! kg8m#util#current_filename() abort  " {{{
  return expand("%:t")
endfunction  " }}}

function! kg8m#util#current_relative_path() abort  " {{{
  return fnamemodify(expand("%"), ":~:.")
endfunction  " }}}

function! kg8m#util#current_absolute_path() abort  " {{{
  return fnamemodify(expand("%"), ":~")
endfunction  " }}}
