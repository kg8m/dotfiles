vim9script

final cache = {}

# cf. .config/bin/should_use_deno
export def ShouldUseDeno(): bool
  if has_key(cache, "use_deno")
    return cache.use_deno
  endif

  # Don’t use my `should_use_deno` script because it has a 10-20 ms overhead.
  if empty($USE_DENO)
    cache.use_deno = OnDenoAppDir() || OnDenopsPluginDir()
  else
    cache.use_deno = ($USE_DENO ==# "1")
  endif

  return cache.use_deno
enddef

def OnDenoAppDir(): bool
  return (
    filereadable("deno.json") ||
    filereadable("deno.jsonc") ||
    filereadable("deno.lock")
  )
enddef

def OnDenopsPluginDir(): bool
  if !isdirectory("denops")
    return false
  endif

  const fd_common_options = "--has-results --hidden --no-ignore --type file"
  system($"fd {fd_common_options} --extension ts --search-path denops")

  if v:shell_error ==# 1
    return false
  endif

  system($"fd {fd_common_options} --extension vim")
  return v:shell_error ==# 0
enddef
