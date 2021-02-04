vim9script

def kg8m#plugin#disable_defaults(): void  # {{{
  g:no_vimrc_example         = true
  g:no_gvimrc_example        = true
  g:loaded_gzip              = true
  g:loaded_tar               = true
  g:loaded_tarPlugin         = true
  g:loaded_zip               = true
  g:loaded_zipPlugin         = true
  g:loaded_rrhelper          = true
  g:loaded_vimball           = true
  g:loaded_vimballPlugin     = true
  g:loaded_getscript         = true
  g:loaded_getscriptPlugin   = true
  g:loaded_netrw             = true
  g:loaded_netrwPlugin       = true
  g:loaded_netrwSettings     = true
  g:loaded_netrwFileHandlers = true
  g:skip_loading_mswin       = true
  g:did_install_syntax_menu  = true

  # MacVim's features, e.g., `Command` + `v` to paste, are broken if setting this
  # g:did_install_default_menus = true
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

  # Decrease max processes because too many processes sometimes get refused
  g:dein#install_max_processes = 4

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
  var enabled = true

  if has_key(options, "merged")
    if options.merged && has_key(options, "if")
      kg8m#util#logger#warn("Don't use `merged: true` with `if` option because merged plugins are always loaded")
    endif
  else
    options.merged = !has_key(options, "if")
  endif

  if !get(options, "if", true)
    # Don't load but fetch the plugin
    options.rtp = ""
    remove(options, "if")
    enabled = false
  endif

  dein#add(plugin_name, options)
  return dein#tap(fnamemodify(plugin_name, ":t")) && enabled
enddef  # }}}

def kg8m#plugin#configure(config: dict<any>): dict<any>  # {{{
  if get(config, "lazy", false)
    config.merged = false
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

def kg8m#plugin#source(plugin_name: string): void  # {{{
  dein#source(plugin_name)
enddef  # }}}

def kg8m#plugin#is_sourced(plugin_name: string): bool  # {{{
  return !!dein#is_sourced(plugin_name)
enddef  # }}}

def kg8m#plugin#all_runtimepath(): string  # {{{
  const current = &runtimepath->split(",")
  const plugins = kg8m#plugin#get_info()
    ->values()
    ->kg8m#util#list#filter_map((plugin) => empty(plugin.rtp) ? false : plugin.rtp)

  return kg8m#util#list#vital().uniq(current + plugins)->join(",")
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
  return kg8m#plugin#get_info()->values()->filter((_, plugin) => empty(plugin.rtp))
enddef  # }}}
