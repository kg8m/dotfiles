vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util/cursor.vim" as cursorUtil
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/logger.vim"

export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    # cf. .config/zsh/bin/rails-routes
    source:  "rails-routes",
    "sink*": Handler,
    options: [
      "--prompt", $"RailsRoutes> ",
      "--header-lines", 1,
      "--expect", g:fzf_action->keys()->join(","),
    ],
  }

  fzf#run(fzf#wrap("rails-routes", options))
enddef

export def Handler(lines: list<string>): void
  if empty(lines)
    return
  endif

  const key = lines[0]
  const command = empty(key) ? "edit" : g:fzf_action[key]

  for line in lines[1 : -1]
    const [controller_name, action_name] = line->matchstr('\v\zs\S+$')->split("#")
    const combined_name = $"{controller_name}#{action_name}"

    const filepath = $"app/controllers/{controller_name}_controller.rb"
    const line_pattern = $'\bdef {action_name}\b'
    const column_pattern = '\vdef \zs'

    if !filereadable(filepath)
      logger.Warn($"{filepath} doesn’t exist (for {combined_name}).")
      continue
    endif

    const [line_number, column_number] = fileUtil.DetectLineAndColumnInFile(filepath, line_pattern, column_pattern)
    execute command fnameescape(filepath)
    cursorUtil.MoveIntoFolding(line_number, column_number)

    if line_number ==# 0 && column_number ==# 0
      logger.Warn($"{combined_name} not found in {filepath}.")
    endif
  endfor
enddef

plugin.EnsureSourced("fzf.vim")
