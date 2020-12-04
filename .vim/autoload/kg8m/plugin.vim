let s:is_update_log_shown = v:false

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

  if has_key(a:options, "merged")
    if a:options.merged && has_key(a:options, "if")
      call kg8m#util#echo_warn_msg("Don't use `merged: v:true` with `if` option because merged plugins are always loaded")
    endif
  else
    let a:options.merged = !has_key(a:options, "if")
  endif

  if !get(a:options, "if", v:true)
    " Don't load but fetch the plugin
    let a:options.rtp = ""
    call remove(a:options, "if")
    let enabled = v:false
  endif

  call dein#add(a:plugin_name, a:options)
  return dein#tap(fnamemodify(a:plugin_name, ":t")) && enabled
endfunction  " }}}

function kg8m#plugin#configure(config) abort  " {{{
  if get(a:config, "lazy", v:false)
    let a:config.merged = v:false
  endif

  return dein#config(a:config)
endfunction  " }}}

function kg8m#plugin#unregister(names) abort  " {{{
  return dein#disable(a:names)
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
  call timer_start(   0, { -> kg8m#plugin#check_and_update(a:options) } )
  call timer_start( 200, { -> kg8m#plugin#remove_disused() })
  call timer_start(1000, { -> kg8m#plugin#show_update_log() })
endfunction  " }}}

function kg8m#plugin#check_and_update(options = {}) abort  " {{{
  " Re-register disabled plugins before update because dein.vim doesn't make helptags for them
  call kg8m#plugin#enable_disabled_plugins()

  if get(a:options, "bulk", v:true)
    let force_update = v:true
    call dein#check_update(force_update)
  else
    call dein#update()
  endif

  call s:check_updating_finished()
endfunction  " }}}

function kg8m#plugin#remove_disused() abort  " {{{
  for dirpath in dein#check_clean()
    call kg8m#util#echo_error_msg("Remove "..dirpath)
    call delete(dirpath, "rf")
  endfor
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

  let s:is_update_log_shown = v:true
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

function kg8m#plugin#recache_runtimepath() abort  " {{{
  call kg8m#plugin#enable_disabled_plugins()
  call dein#recache_runtimepath()
endfunction  " }}}

function kg8m#plugin#enable_disabled_plugins() abort  " {{{
  for plugin in kg8m#plugin#disabled_plugins()
    let options = copy(plugin.orig_opts)
    call remove(options, "rtp")

    call kg8m#plugin#unregister(plugin.name)
    call kg8m#plugin#register(plugin.repo, options)
  endfor
endfunction  " }}}

function kg8m#plugin#disabled_plugins() abort  " {{{
  return kg8m#plugin#get_info()->values()->filter("v:val.rtp->empty()")
endfunction  " }}}

function s:check_updating_finished(options = {}) abort  " {{{
  let options = copy(a:options)

  if !has_key(options, "start_time")
    let options.start_time = localtime()
  endif

  if s:is_update_log_shown && execute("messages") =~# '\v\[dein\] Done:'
    let should_stay = (localtime() - options.start_time) > 30
    call s:notify_updating("Finished.", #{ stay: should_stay })
  else
    let progress      = dein#install#_get_progress()
    let prev_progress = get(options, "prev_progress", v:null)
    let retry_count   = get(options, "retry_count", 0)

    " Clear echo messages because they are noisy if multi-line
    redraw

    " Respect dein.vim's original message
    echo "[dein] "..progress

    if progress ==# prev_progress
      let retry_count += 1

      if retry_count > 100
        call s:notify_updating("Something is wrong.", #{ stay: v:true, level: "error" })
        return
      endif
    else
      let retry_count = 0
    endif

    let options.prev_progress = progress
    let options.retry_count   = retry_count
    call timer_start(300, { -> s:check_updating_finished(options) })
  endif
endfunction  " }}}

function s:notify_updating(message, options = {}) abort  " {{{
  let is_stay = get(a:options, "stay", v:false)
  let level   = get(a:options, "level", "warn")

  let hostname = system("hostname")->trim()
  let title    = "Updating Vim plugins"

  let notify_command = (
  \   [
  \     "/usr/local/bin/terminal-notifier",
  \     "-title", title,
  \     "-message", "\\["..hostname.."] "..a:message,
  \     "-group", "UPDATING_VIM_PLUGINS_FINISHED_"..hostname,
  \   ] + (
  \     is_stay ? ["-sender", "TERMINAL_NOTIFIER_STAY"] : []
  \   )
  \ )->map("shellescape(v:val)")->join(" ")

  call job_start(["ssh", "main", "-t", notify_command])

  let message = title..": "..a:message
  if level ==# "warn"
    call kg8m#util#echo_warn_msg(message)
  else
    call kg8m#util#echo_error_msg(message)
  endif
endfunction  " }}}
