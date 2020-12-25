vim9script

var s:is_update_log_shown = v:false

def kg8m#plugin#disable_defaults(): void  # {{{
  g:no_vimrc_example         = v:true
  g:no_gvimrc_example        = v:true
  g:loaded_gzip              = v:true
  g:loaded_tar               = v:true
  g:loaded_tarPlugin         = v:true
  g:loaded_zip               = v:true
  g:loaded_zipPlugin         = v:true
  g:loaded_rrhelper          = v:true
  g:loaded_vimball           = v:true
  g:loaded_vimballPlugin     = v:true
  g:loaded_getscript         = v:true
  g:loaded_getscriptPlugin   = v:true
  g:loaded_netrw             = v:true
  g:loaded_netrwPlugin       = v:true
  g:loaded_netrwSettings     = v:true
  g:loaded_netrwFileHandlers = v:true
  g:skip_loading_mswin       = v:true
  g:did_install_syntax_menu  = v:true

  # MacVim's features, e.g., `Command` + `v` to paste, are broken if setting this
  # g:did_install_default_menus = v:true
enddef  # }}}

def kg8m#plugin#init_manager(): void  # {{{
  const plugins_path = expand("~/.vim/plugins")
  const manager_path = expand(plugins_path .. "/repos/github.com/Shougo/dein.vim")

  if !isdirectory(manager_path)
    echo "Installing plugin manager..."
    system("git clone https://github.com/Shougo/dein.vim " .. manager_path)
  endif

  &runtimepath ..= "," .. manager_path
  dein#begin(plugins_path)

  augroup kg8m-plugin  # {{{
    autocmd!
    autocmd VimEnter * kg8m#plugin#call_hooks()
  augroup END  # }}}

  g:dein#install_github_api_token = $DEIN_INSTALL_GITHUB_API_TOKEN

  kg8m#plugin#register(manager_path)
enddef  # }}}

def kg8m#plugin#call_hooks(): void  # {{{
  dein#call_hook("source")
  dein#call_hook("post_source")
enddef  # }}}

def kg8m#plugin#finish_setup(): void  # {{{
  dein#end()
enddef  # }}}

def kg8m#plugin#register(plugin_name: string, options: dict<any> = {}): bool  # {{{
  var enabled = v:true

  if has_key(options, "merged")
    if options.merged && has_key(options, "if")
      kg8m#util#echo_warn_msg("Don't use `merged: v:true` with `if` option because merged plugins are always loaded")
    endif
  else
    options.merged = !has_key(options, "if")
  endif

  if !get(options, "if", v:true)
    # Don't load but fetch the plugin
    options.rtp = ""
    remove(options, "if")
    enabled = v:false
  endif

  dein#add(plugin_name, options)
  return dein#tap(fnamemodify(plugin_name, ":t")) && enabled
enddef  # }}}

def kg8m#plugin#configure(config: dict<any>): dict<any>  # {{{
  if get(config, "lazy", v:false)
    config.merged = v:false
  endif

  return dein#config(config)
enddef  # }}}

def kg8m#plugin#unregister(plugin_name_or_names: any): void  # {{{
  dein#disable(plugin_name_or_names)
enddef  # }}}

def kg8m#plugin#get_info(plugin_name: string = ""): any  # {{{
  if empty(plugin_name)
    return dein#get()
  else
    return dein#get(plugin_name)
  endif
enddef  # }}}

def kg8m#plugin#installable_exists(plugin_names: list<string> = []): bool  # {{{
  if empty(plugin_names)
    return !!dein#check_install()
  else
    return !!dein#check_install(plugin_names)
  endif
enddef  # }}}

def kg8m#plugin#install(plugin_names: list<string> = []): void  # {{{
  if empty(plugin_names)
    dein#install()
  else
    dein#install(plugin_names)
  endif
enddef  # }}}

def kg8m#plugin#update_all(options: dict<any> = {}): void  # {{{
  timer_start(   0, { -> kg8m#plugin#check_and_update(options) } )
  timer_start( 200, { -> kg8m#plugin#remove_disused() })
  timer_start(1000, { -> kg8m#plugin#show_update_log() })
enddef  # }}}

def kg8m#plugin#check_and_update(options: dict<any> = {}): void  # {{{
  # Re-register disabled plugins before update because dein.vim doesn't make helptags for them
  kg8m#plugin#enable_disabled_plugins()

  if get(options, "bulk", v:true)
    const force_update = v:true
    dein#check_update(force_update)
  else
    dein#update()
  endif

  s:check_updating_finished()
enddef  # }}}

def kg8m#plugin#remove_disused(): void  # {{{
  for dirpath in dein#check_clean()
    kg8m#util#echo_error_msg("Remove " .. dirpath)
    delete(dirpath, "rf")
  endfor
enddef  # }}}

def kg8m#plugin#show_update_log(): void  # {{{
  const initial_input =
    '!Same\\ revision'
    .. '\ !Current\\ branch\\ *\\ is\\ up\\ to\\ date.'
    .. '\ !^$'
    .. '\ !(*/*)\\ [+'
    .. '\ !(*/*)\\ [-'
    .. '\ !Created\\ autostash'
    .. '\ !Applied\\ autostash'
    .. '\ !HEAD\\ is\\ now'
    .. '\ !\\ *->\\ origin/'
    .. '\ !^First,\\ rewinding\\ head\\ to\\ replay\\ your\\ work\\ on\\ top\\ of\\ it'
    .. '\ !^Fast-forwarded\\ *\\ to'
    .. '\ !^(.*/.*)\\ From\\ '
    .. '\ !Successfully\\ rebased\\ and\\ updated\\ refs/heads/'
    .. '\ !*\\ [new\\ tag]'
    .. '\ !already\\ exists,\\ disabling\\ multiplexing'
    .. '\ !refs/remotes/origin/HEAD\\ has\\ become\\ dangling'
    .. '\ !origin/HEAD\\ set\\ to'
    .. '\ !Your\\ configuration\\ specifies\\ to\\ merge\\ with\\ the\\ ref'
    .. '\ !from\\ the\\ remote,\\ but\\ no\\ such\\ ref\\ was\\ fetched.'

  execute "Unite dein/log -buffer-name=update_plugins -input=" .. initial_input

  # Press `n` key to search "Updated"
  @/ = "Updated"

  s:is_update_log_shown = v:true
enddef  # }}}

def kg8m#plugin#source(plugin_name: string): void  # {{{
  dein#source(plugin_name)
enddef  # }}}

def kg8m#plugin#is_sourced(plugin_name: string): bool  # {{{
  return !!dein#is_sourced(plugin_name)
enddef  # }}}

def kg8m#plugin#all_runtimepath(): string  # {{{
  const current = &runtimepath->split(",")
  const plugins = kg8m#plugin#get_info()->values()->filter("!v:val.rtp->empty()")->map("v:val.rtp")

  return kg8m#util#list_module().uniq(current + plugins)->join(",")
enddef  # }}}

def kg8m#plugin#recache_runtimepath(): void  # {{{
  kg8m#plugin#enable_disabled_plugins()
  dein#recache_runtimepath()
enddef  # }}}

def kg8m#plugin#enable_disabled_plugins(): void  # {{{
  for plugin in kg8m#plugin#disabled_plugins()
    final options = copy(plugin.orig_opts)
    remove(options, "rtp")

    kg8m#plugin#unregister(plugin.name)
    kg8m#plugin#register(plugin.repo, options)
  endfor
enddef  # }}}

def kg8m#plugin#disabled_plugins(): list<dict<any>>  # {{{
  return kg8m#plugin#get_info()->values()->filter("v:val.rtp->empty()")
enddef  # }}}

def s:check_updating_finished(options: dict<any> = {}): void  # {{{
  final options_cache = copy(options)

  if !has_key(options_cache, "start_time")
    options_cache.start_time = localtime()
  endif

  if s:is_update_log_shown && execute("messages") =~# '\v\[dein\] Done:'
    const should_stay = (localtime() - options_cache.start_time) > 30
    s:notify_updating("Finished.", { stay: should_stay })
  else
    const progress      = dein#install#_get_progress()
    const prev_progress = get(options_cache, "prev_progress", v:null)
    var   retry_count   = get(options_cache, "retry_count", 0)

    # Clear echo messages because they are noisy if multi-line
    redraw

    # Respect dein.vim's original message
    echo "[dein] " .. progress

    if progress ==# prev_progress
      retry_count += 1

      if retry_count > 100
        s:notify_updating("Something is wrong.", { stay: v:true, level: "error" })
        return
      endif
    else
      retry_count = 0
    endif

    options_cache.prev_progress = progress
    options_cache.retry_count   = retry_count
    timer_start(300, { -> s:check_updating_finished(options_cache) })
  endif
enddef  # }}}

def s:notify_updating(message: string, options: dict<any> = {}): void  # {{{
  const is_stay = get(options, "stay", v:false)
  const level   = get(options, "level", "warn")

  const hostname = system("hostname")->trim()
  const title    = "Updating Vim plugins"

  final notify_command = [
    "/usr/local/bin/terminal-notifier",
    "-title", title,
    "-message", "\\[" .. hostname .. "] " .. message,
    "-group", "UPDATING_VIM_PLUGINS_FINISHED_" .. hostname,
  ]

  if is_stay
    extend(notify_command, ["-sender", "TERMINAL_NOTIFIER_STAY"])
  endif

  notify_command->map("shellescape(v:val)")
  job_start(["ssh", "main", "-t", notify_command->join(" ")])

  const message_with_title = title .. ": " .. message

  if level ==# "warn"
    kg8m#util#echo_warn_msg(message_with_title)
  else
    kg8m#util#echo_error_msg(message_with_title)
  endif
enddef  # }}}
