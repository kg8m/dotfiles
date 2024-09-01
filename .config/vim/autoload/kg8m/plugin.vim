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

  # MacVim’s features, e.g., `Command` + `v` to paste, are broken if setting this
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

  # Disable copying files via Vim’s `readfile()` and `writefile()` because it is too slow.
  g:dein#install_copy_vim = false

  # Decrease max processes because too many requests sometimes get refused by GitHub.
  # Don’t use `1` because it causes busy loop.
  g:dein#install_max_processes = 2

  # With `--filter=blob:none`
  g:dein#types#git#enable_partial_clone = true

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
      logger.Warn("Don’t use `merged: true` with `if` option because merged plugins are always loaded")
    endif
  else
    options.merged = !has_key(options, "if")
  endif

  if !get(options, "if", true)
    # Don’t load but fetch the plugin
    options.rtp = ""
    remove(options, "if")
    enabled = false
  endif

  # Skip dein.vim’s unnecessary parsing

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

# Manually source a plugin because of some reasons, e.g., dein.vim’s `on_func` feature is not available in Vim9 script.
# Vim9 script doesn’t support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
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

# Check if there are renamed plugins.
# Renamed plugins can’t be updated by `dein#check_update()`.
export def CheckRenamedPlugins(): void
  const Echo = (message) => {
    echo $"[CheckRenamedPlugins] {message}"
  }
  const Info = (message) => logger.Info($"[CheckRenamedPlugins] {message}")
  const Warn = (message) => logger.Warn($"[CheckRenamedPlugins] {message}")

  EnableDisabledPlugins()

  final results = { skipped: [], renamed: [], unknown: [] }
  var i = 0
  for plugin in GetInfo()->values()->sort((lhs, rhs) => tolower(lhs.repo) <# tolower(rhs.repo) ? -1 : 1)
    redraw!
    Echo($"Checking {plugin.repo}...")

    i += 1

    # Skip a plugin with `@` or `:`, e.g., `git@github.com:...`
    if plugin.repo =~# '\v[@:]'
      results.skipped += [plugin]
      continue
    endif

    const response = system($"curl --silent --head --request HEAD https://github.com/{plugin.repo}")
    const status   = matchstr(response, '\v(^|\r?\n)HTTP\S+\s+\zs\d{3}\ze')

    if status =~# '^2'
      # OK
      continue
    elseif status =~# '^3'
      const new_repo = matchstr(response, '\v(^|\r?\n)location: https://github\.com/\zs[^[:space:]]+\ze')
      results.renamed += [{ plugin: plugin, new_repo: new_repo }]
    else
      results.unknown += [{ plugin: plugin, status: status }]
    endif

    if i % 10 ==# 0
      sleep 1
    endif
  endfor

  redraw!

  if !empty(results.skipped)
    Info($"Skipped plugins: {results.skipped->mapnew((_, plugin) => plugin.repo)->join(", ")}")
  endif

  if !empty(results.renamed)
    for result in results.renamed
      Info($"Renamed plugin: {result.plugin.repo} => {result.new_repo}")
    endfor
  endif

  if !empty(results.unknown)
    for result in results.unknown
      Warn($"Unknown response status: {result.status} (plugin: {result.plugin.repo})")
    endfor
  endif

  Info("Done.")
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

    # Use timer because synchronous messages are hidden by Vim’s default written message on `BufWritePost` event.
    timer_start(100, (_) => logger.Info("Runtimepath recached!!"))
  endif
enddef
