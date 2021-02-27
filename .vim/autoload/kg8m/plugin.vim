vim9script

if !isdirectory($VIM_PLUGINS)
  throw "`$VIM_PLUGINS` is not a directory."
endif

const PLUGINS_DIRPATH    = fnamemodify($VIM_PLUGINS, ":h")
const MANAGER_REPOSITORY = "Shougo/dein.vim"

final s:on_start_queue = []

def kg8m#plugin#disable_defaults(): void
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
enddef

def kg8m#plugin#init_manager(): void
  const manager_path = expand(PLUGINS_DIRPATH .. "/repos/github.com/" .. MANAGER_REPOSITORY)

  if !isdirectory(manager_path)
    echo "Installing plugin manager..."
    system("git clone https://github.com/" .. MANAGER_REPOSITORY .. " " .. manager_path)
  endif

  &runtimepath ..= "," .. manager_path
  dein#begin(PLUGINS_DIRPATH)
  kg8m#plugin#register(MANAGER_REPOSITORY, { if: false })

  augroup kg8m-plugin
    autocmd!
    autocmd VimEnter * kg8m#plugin#call_hooks()
    autocmd VimEnter * timer_start(0, () => s:source_on_start())
  augroup END

  # Decrease max processes because too many processes sometimes get refused
  g:dein#install_max_processes = 4

  g:dein#install_github_api_token = $DEIN_INSTALL_GITHUB_API_TOKEN
enddef

def kg8m#plugin#call_hooks(): void
  dein#call_hook("source")
  dein#call_hook("post_source")
enddef

def kg8m#plugin#finish_setup(): void
  dein#end()
enddef

def kg8m#plugin#register(repository: string, options: dict<any> = {}): bool
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

  # Skip dein.vim's unnecessary parsing

  if !has_key(options, "name")
    options.name = fnamemodify(repository, ":t")
  endif

  if !has_key(options, "normalized_name")
    options.normalized_name = options.name
  endif

  if !has_key(options, "lazy")
    options.lazy = false
  endif

  dein#add(repository, options)
  return dein#tap(options.normalized_name) && enabled
enddef

def kg8m#plugin#configure(config: dict<any>): dict<any>
  if get(config, "lazy", false)
    config.merged = false
  endif

  if get(config, "on_start", false)
    remove(config, "on_start")
    add(s:on_start_queue, g:dein#plugin.name)
  endif

  return dein#config(config)
enddef

def kg8m#plugin#unregister(plugin_name_or_names: any): void
  dein#disable(plugin_name_or_names)
enddef

def kg8m#plugin#get_info(plugin_name: string = ""): any
  if empty(plugin_name)
    return dein#get()
  else
    return dein#get(plugin_name)
  endif
enddef

def kg8m#plugin#installable_exists(plugin_names: list<string> = []): bool
  if empty(plugin_names)
    return !!dein#check_install()
  else
    return !!dein#check_install(plugin_names)
  endif
enddef

def kg8m#plugin#install(plugin_names: list<string> = []): void
  if empty(plugin_names)
    dein#install()
  else
    dein#install(plugin_names)
  endif
enddef

def kg8m#plugin#source(plugin_name: string): void
  dein#source(plugin_name)
enddef

def kg8m#plugin#is_sourced(plugin_name: string): bool
  return !!dein#is_sourced(plugin_name)
enddef

def kg8m#plugin#all_runtimepath(): string
  const current = &runtimepath->split(",")
  const plugins = kg8m#plugin#get_info()
    ->values()
    ->kg8m#util#list#filter_map((plugin) => empty(plugin.rtp) ? false : plugin.rtp)

  return kg8m#util#list#vital().uniq(current + plugins)->join(",")
enddef

def kg8m#plugin#recache_runtimepath(): void
  kg8m#plugin#enable_disabled_plugins()
  dein#recache_runtimepath()
enddef

def kg8m#plugin#enable_disabled_plugins(): void
  for plugin in kg8m#plugin#disabled_plugins()
    final options = copy(plugin.orig_opts)
    remove(options, "rtp")

    kg8m#plugin#unregister(plugin.name)
    kg8m#plugin#register(plugin.repo, options)
  endfor
enddef

def kg8m#plugin#disabled_plugins(): list<dict<any>>
  return kg8m#plugin#get_info()->values()->filter((_, plugin) => empty(plugin.rtp))
enddef

# Source lazily but early to optimize sourcing many plugins
def s:source_on_start(): void
  if !empty(s:on_start_queue)
    const plugin_name = remove(s:on_start_queue, 0)

    timer_start(50, () => kg8m#plugin#is_sourced(plugin_name) ? v:null : kg8m#plugin#source(plugin_name))
    timer_start(50, () => s:source_on_start())
  endif
enddef
