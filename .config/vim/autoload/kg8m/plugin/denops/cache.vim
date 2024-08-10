vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util/list.vim" as listUtil

export def UpdateAll(): void
  EnableAllPlugins()
  denops#cache#update({ reload: true })
enddef

def EnableAllPlugins(): void
  const plugin_names = AllPluginExternalNames()

  for plugin_name in plugin_names
    plugin.EnsureSourced(plugin_name)
  endfor

  denops#server#start()
  denops#server#wait()

  for external_name in plugin_names
    denops#plugin#wait(ExtractPluginInternalName(external_name))
  endfor
enddef

def AllPluginExternalNames(): list<string>
  return plugin.GetInfo()->values()->listUtil.FilterMap(
    (info) => listUtil.Includes(get(info, "depends", []), "denops.vim") ? info.name : false
  )
enddef

def ExtractPluginInternalName(external_name: string): string
  return matchstr(external_name, '\v^%(vim-)?%(dps-)?\zs.{-}\ze%(\.vim)?$')
enddef
