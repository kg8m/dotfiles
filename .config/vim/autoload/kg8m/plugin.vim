vim9script

import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/string.vim" as stringUtil

if !isdirectory($VIM_PLUGINS)
  throw "`$VIM_PLUGINS` is not a directory."
endif

const PLUGINS_DIRPATH    = fnamemodify($VIM_PLUGINS, ":h")
const MANAGER_REPOSITORY = "Shougo/dein.vim"

# Check remote if the repository is updated within 2 days.
const CHECK_REMOTE_THRESHOLD = 2 * 24 * 60 * 60

final cache = {
  on_start_queue: [],
}

augroup vimrc-plugin
  autocmd!
  autocmd BufWritePost * RecachePluginsIfNeeded()
  autocmd User all_on_start_plugins_sourced ++once :
augroup END

export def DisableDefaults(): void
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

export def InitManager(): void
  const manager_path = $"{PLUGINS_DIRPATH}/repos/github.com/{MANAGER_REPOSITORY}"

  if !isdirectory(manager_path)
    echo "Installing plugin manager..."
    system($"git clone https://github.com/{MANAGER_REPOSITORY} {manager_path}")
  endif

  &runtimepath ..= $",{manager_path}"
  dein#begin(PLUGINS_DIRPATH)
  Register(MANAGER_REPOSITORY, { if: false })

  augroup kg8m-plugin
    autocmd!
    autocmd VimEnter * timer_start(100, (_) => DequeueOnStart())
  augroup END

  g:dein#install_check_diff = true
  g:dein#install_check_remote_threshold = CHECK_REMOTE_THRESHOLD
  g:dein#install_github_api_token = $DEIN_INSTALL_GITHUB_API_TOKEN

  # Disable copying files via Vim's `readfile()` and `writefile()` because it is too slow.
  g:dein#install_copy_vim = false

  # Decrease max processes because too many requests sometimes get refused by GitHub.
  # Don't use `1` because it causes busy loop.
  g:dein#install_max_processes = 2

  # Default: "pull --ff --ff-only"
  g:dein#types#git#pull_command = "pull"
enddef

export def FinishSetup(): void
  dein#end()
enddef

export def Register(repository: string, options: dict<any> = {}): bool
  var enabled = true

  if has_key(options, "merged")
    if options.merged && has_key(options, "if")
      logger.Warn("Don't use `merged: true` with `if` option because merged plugins are always loaded")
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

  if get(options, "on_start", false)
    remove(options, "on_start")
    add(cache.on_start_queue, options.name)
  endif

  dein#add(repository, options)
  return dein#tap(options.normalized_name) && enabled
enddef

export def Configure(config: dict<any>): dict<any>
  if get(config, "lazy", false)
    config.merged = false
  endif

  if get(config, "on_start", false)
    remove(config, "on_start")
    add(cache.on_start_queue, g:dein#plugin.name)
  endif

  return dein#config(config)
enddef

export def Unregister(plugin_name_or_names: any): void
  dein#disable(plugin_name_or_names)
enddef

export def GetInfo(plugin_name: string = ""): any
  if empty(plugin_name)
    return dein#get()
  else
    return dein#get(plugin_name)
  endif
enddef

export def InstallableExists(plugin_names: list<string> = []): bool
  if empty(plugin_names)
    return !!dein#check_install()
  else
    return !!dein#check_install(plugin_names)
  endif
enddef

export def Install(plugin_names: list<string> = []): void
  if empty(plugin_names)
    dein#install()
  else
    dein#install(plugin_names)
  endif
enddef

export def Source(plugin_name: string): void
  dein#source(plugin_name)
enddef

export def IsSourced(plugin_name: string): bool
  return !!dein#is_sourced(plugin_name)
enddef

# Manually source a plugin because of some reasons, e.g., dein.vim's `on_func` feature is not available in Vim9 script.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
export def EnsureSourced(plugin_name: string): void
  if !IsSourced(plugin_name)
    Source(plugin_name)
  endif
enddef

export def AllRuntimepath(): string
  const current = &runtimepath->split(",")
  const plugins = GetInfo()
    ->values()
    ->listUtil.FilterMap((plugin) => empty(plugin.rtp) ? false : plugin.rtp)

  return listUtil.Union(current, plugins)->join(",")
enddef

export def RecacheRuntimepath(): void
  EnableDisabledPlugins()
  dein#recache_runtimepath()
enddef

export def EnableDisabledPlugins(): void
  for plugin in DisabledPlugins()
    final options = copy(plugin.orig_opts)
    remove(options, "rtp")

    Unregister(plugin.name)
    Register(plugin.repo, options)
  endfor
enddef

export def DisabledPlugins(): list<dict<any>>
  return GetInfo()->values()->filter((_, plugin) => empty(plugin.rtp))
enddef

# Source lazily but early to optimize sourcing many plugins
def DequeueOnStart(): void
  if empty(cache.on_start_queue)
    doautocmd <nomodeline> User all_on_start_plugins_sourced
  else
    const plugin_name = remove(cache.on_start_queue, 0)
    timer_start(100, (_) => SourceOnStart(plugin_name))
  endif
enddef

def SourceOnStart(plugin_name: string): void
  EnsureSourced(plugin_name)
  DequeueOnStart()
enddef

export def AreAllOnStartPluginsSourced(): bool
  return empty(cache.on_start_queue)
enddef

def RecachePluginsIfNeeded(): void
  if stringUtil.StartsWith(getcwd(), $VIM_PLUGINS)
    RecacheRuntimepath()

    # Use timer because synchronous messages are hidden by Vim's default written message on `BufWritePost` event.
    timer_start(100, (_) => logger.Info("Runtimepath recached!!"))
  endif
enddef
