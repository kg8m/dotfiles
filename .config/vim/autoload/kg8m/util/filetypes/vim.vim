vim9script

final cache = {
  runtimepath: "",
  search_path_options: [],
}

export def FindAutoloadFile(autoload_filepath: string): string
  # `$FD_DEFAULT_OPTIONS` is always an empty string when evaluated in Vim because it is a array in shell.
  # So don’t evaluate it in Vim but evaluate it in shell.
  final base_command = ["fd", "${FD_DEFAULT_OPTIONS}", "${FD_EXTRA_OPTIONS}", "--fixed-strings", "--full-path", "--max-results", "1"]

  if &runtimepath !=# cache.runtimepath
    cache.runtimepath = &runtimepath
    cache.search_path_options = []

    for runtimepath in cache.runtimepath->split(",")
      if isdirectory(runtimepath)
        cache.search_path_options += ["--search-path", shellescape(runtimepath)]
      endif
    endfor
  endif

  const command = base_command + cache.search_path_options + [shellescape(autoload_filepath)]
  return command->join(" ")->system()->trim()
enddef
