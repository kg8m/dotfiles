function kg8m#plugin#init_manager() abort  " {{{
  let plugins_path = expand("~/.vim/plugins")
  let manager_path = expand(plugins_path.."/repos/github.com/Shougo/dein.vim")

  if !isdirectory(manager_path)
    echo "Installing plugin manager..."
    call system("git clone https://github.com/Shougo/dein.vim "..manager_path)
  endif

  let &runtimepath .= ","..manager_path
  let result = dein#begin(plugins_path)

  augroup kg8m-plugin  " {{{
    autocmd!
    autocmd VimEnter * call kg8m#plugin#call_hooks()
  augroup END  " }}}

  let g:dein#install_github_api_token = $DEIN_INSTALL_GITHUB_API_TOKEN

  call kg8m#plugin#register(manager_path)
  return result
endfunction  " }}}

function kg8m#plugin#call_hooks() abort  " {{{
  call dein#call_hook("source")
  call dein#call_hook("post_source")
endfunction  " }}}

function kg8m#plugin#finish_setup() abort  " {{{
  return dein#end()
endfunction  " }}}

function kg8m#plugin#register(plugin_name, options = {}) abort  " {{{
  let enabled = v:true

  if has_key(a:options, "if")
    if !a:options["if"]
      " Don't load but fetch the plugin
      let a:options["rtp"] = ""
      call remove(a:options, "if")
      let enabled = v:false
    endif
  else
    " Sometimes dein doesn't add runtimepath if no options given
    let a:options["if"] = v:true
  endif

  call dein#add(a:plugin_name, a:options)
  return dein#tap(fnamemodify(a:plugin_name, ":t")) && enabled
endfunction  " }}}

function kg8m#plugin#configure(arg, options = {}) abort  " {{{
  return dein#config(a:arg, a:options)
endfunction  " }}}

function kg8m#plugin#get_info(...) abort  " {{{
  if empty(a:000)
    return dein#get()
  else
    return dein#get(get(a:000, 0))
  endif
endfunction  " }}}

function kg8m#plugin#installable_exists(...) abort  " {{{
  if empty(a:000)
    return dein#check_install()
  else
    return dein#check_install(get(a:000, 0))
  endif
endfunction  " }}}

function kg8m#plugin#install(...) abort  " {{{
  if empty(a:000)
    return dein#install()
  else
    return dein#install(get(a:000, 0))
  endif
endfunction  " }}}

function kg8m#plugin#update_all(options = {}) abort  " {{{
  call timer_start(200, { -> kg8m#plugin#remove_disused() })

  echo "Check and update plugins..."
  silent call kg8m#plugin#check_and_update(a:options)

  call timer_start(1000, { -> kg8m#plugin#show_update_log() })
endfunction  " }}}

function kg8m#plugin#remove_disused() abort  " {{{
  call map(dein#check_clean(), "delete(v:val, 'rf')")
endfunction  " }}}

function kg8m#plugin#check_and_update(options = {}) abort  " {{{
  " Load all plugins before update because dein.vim doesn't make helptags for non-loaded plugins
  for plugin in kg8m#plugin#disabled_plugins()
    call kg8m#plugin#register(plugin.repo)
    call kg8m#plugin#source(plugin.name)
  endfor

  if get(a:options, "bulk", v:true)
    let force_update = v:true
    call dein#check_update(force_update)
  else
    call dein#update()
  endif
endfunction  " }}}

function kg8m#plugin#show_update_log() abort  " {{{
  let initial_input =
  \   '!Same\\ revision'
  \   ..'\ !Current\\ branch\\ master\\ is\\ up\\ to\\ date.'
  \   ..'\ !^$'
  \   ..'\ !(*/*)\\ [+'
  \   ..'\ !(*/*)\\ [-'
  \   ..'\ !Created\\ autostash'
  \   ..'\ !Applied\\ autostash'
  \   ..'\ !HEAD\\ is\\ now'
  \   ..'\ !\\ *->\\ origin/'
  \   ..'\ !^First,\\ rewinding\\ head\\ to\\ replay\\ your\\ work\\ on\\ top\\ of\\ it'
  \   ..'\ !^Fast-forwarded\\ master\\ to'
  \   ..'\ !^(.*/.*)\\ From\\ '
  \   ..'\ !Successfully\\ rebased\\ and\\ updated\\ refs/heads/master.'
  \   ..'\ !*\\ [new\\ tag]'
  \   ..'\ !already\\ exists,\\ disabling\\ multiplexing'
  \   ..'\ !refs/remotes/origin/HEAD\\ has\\ become\\ dangling'
  \   ..'\ !origin/HEAD\\ set\\ to'
  \   ..'\ !Your\\ configuration\\ specifies\\ to\\ merge\\ with\\ the\\ ref'
  \   ..'\ !from\\ the\\ remote,\\ but\\ no\\ such\\ ref\\ was\\ fetched.'

  execute "Unite dein/log -buffer-name=update_plugins -input="..initial_input

  " Press `n` key to search "Updated"
  let @/ = "Updated"
endfunction  " }}}

function kg8m#plugin#source(plugin_name) abort  " {{{
  return dein#source(a:plugin_name)
endfunction  " }}}

function kg8m#plugin#is_sourced(plugin_name) abort  " {{{
  return dein#is_sourced(a:plugin_name)
endfunction  " }}}

function kg8m#plugin#all_runtimepath() abort  " {{{
  let current = &runtimepath->split(",")
  let plugins = kg8m#plugin#get_info()->values()->filter("!v:val.rtp->empty()")->map("v:val.rtp")

  return kg8m#util#list_module().uniq(current + plugins)->join(",")
endfunction  " }}}

function kg8m#plugin#disabled_plugins() abort  " {{{
  return kg8m#plugin#get_info()->values()->filter("v:val.rtp->empty()")
endfunction  " }}}
