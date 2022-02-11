vim9script

final s:cache = {
  runtimepath: "",
  search_path_options: [],
}

export def FindAutoloadFile(autoload_filepath: string): string
  final base_command = ["fd", "--hidden", "--no-ignore", "--fixed-strings", "--full-path", "--max-results", "1"]

  if &runtimepath !=# s:cache.runtimepath
    s:cache.runtimepath = &runtimepath
    s:cache.search_path_options = []

    for runtimepath in s:cache.runtimepath->split(",")
      if isdirectory(runtimepath)
        s:cache.search_path_options += ["--search-path", shellescape(runtimepath)]
      endif
    endfor
  endif

  const command = base_command + s:cache.search_path_options + [shellescape(autoload_filepath)]
  return command->join(" ")->system()->trim()
enddef
