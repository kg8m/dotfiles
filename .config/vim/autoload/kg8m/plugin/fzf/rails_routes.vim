vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf_tjump.vim" as fzfTjump
import autoload "kg8m/util/cursor.vim" as cursorUtil
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/logger.vim"

# Routing Examples:
#
#                        Prefix Verb   URI Pattern                                   Controller#Action
#       some_namespace_examples GET    /some_namespace/examples(.:format)            some_namespace/examples#index
#                               POST   /some_namespace/examples(.:format)            some_namespace/examples#create
#    new_some_namespace_example GET    /some_namespace/examples/new(.:format)        some_namespace/examples#new
#   edit_some_namespace_example GET    /some_namespace/examples/:id/edit(.:format)   some_namespace/examples#edit
#        some_namespace_example GET    /some_namespace/examples/:id(.:format)        some_namespace/examples#show
#                               PATCH  /some_namespace/examples/:id(.:format)        some_namespace/examples#update
#                               PUT    /some_namespace/examples/:id(.:format)        some_namespace/examples#update
#                               DELETE /some_namespace/examples/:id(.:format)        some_namespace/examples#destroy
#                               GET    /some_namespace/examples/something1(.:format) some_namespace/examples#something1 {:host=>"example.com"}
#                                      /some_namespace/examples/something2(.:format) #<Proc:...>
#                  some_library        /some_namespace/some_library                  SomeLibrary::Engine

const PREFIX_PART_PATTERN = '\v[_0-9a-z]+'                           # e.g., some_namespace_example, some_library, and so on
const VERB_PART_PATTERN = '\v[A-Z]+'                                 # e.g., GET, POST, and so on
const PATH_PART_PATTERN = '\v\S+'                                    # e.g., /some_namespace/examples(.:format), /some_namespace/some_library, and so on
const DESTINATION_PART_PATTERN_FOR_CONTROLLER_ACTION = '\v\S+#\w+'   # e.g., some_namespace/examples#index, some_namespace/something1, and so on
const DESTINATION_PART_PATTERN_FOR_PROC = '\v#\<Proc:[^>]+\>'        # e.g., #<Proc:...>
const DESTINATION_PART_PATTERN_FOR_CLASS = '\v[A-Z][-:_0-9A-Za-z]+'  # e.g., SomeLibrary::Engine
const DESTINATION_PART_PATTERN = $'{DESTINATION_PART_PATTERN_FOR_CONTROLLER_ACTION}|{DESTINATION_PART_PATTERN_FOR_PROC}|{DESTINATION_PART_PATTERN_FOR_CLASS}'
const OPTIONS_PART_PATTERN = '\v\{.+\}'                              # e.g., {:host=>"example.com"}

const ROUTING_LINE_PATTERN = $'\v\C^\s*({PREFIX_PART_PATTERN})?\s+({VERB_PART_PATTERN})?\s+({PATH_PART_PATTERN})\s+({DESTINATION_PART_PATTERN})\s*({OPTIONS_PART_PATTERN})?$'

final queue_for_class_destinations = []

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

  if !empty(queue_for_class_destinations)
    remove(queue_for_class_destinations, 0, -1)
  endif

  for line in lines[1 : -1]
    const compact_line = line->substitute('\v\s{2,}', " ", "g")->trim()
    const routing_parts = matchlist(line, ROUTING_LINE_PATTERN)

    if empty(routing_parts)
      logger.Warn($"Maybe not a routing line: {string(compact_line)}.")
      continue
    endif

    const [_line, _prefix, _verb, _path, destination, _options; _] = routing_parts

    if destination =~# DESTINATION_PART_PATTERN_FOR_CONTROLLER_ACTION
      GoToDestinationForControllerAction(destination, command)
    elseif destination =~# DESTINATION_PART_PATTERN_FOR_PROC
      logger.Warn($"Proc destination pattern not supported (line: {string(compact_line)}).")
    elseif destination =~# DESTINATION_PART_PATTERN_FOR_CLASS
      add(queue_for_class_destinations, { destination: destination, line: compact_line })
    else
      logger.Warn($"Unknown destination pattern: {destination} (line: {string(compact_line)}).")
    endif
  endfor

  timer_start(10, (_) => DequeueForClassDestinations())
enddef

def GoToDestinationForControllerAction(destination: string, command_to_edit: string): void
  const [controller_name, action_name] = split(destination, "#")

  const filepath = $"app/controllers/{controller_name}_controller.rb"
  const line_pattern = $'\bdef {action_name}\b'
  const column_pattern = '\vdef \zs'

  if !filereadable(filepath)
    logger.Warn($"{filepath} doesn’t exist (for {destination}).")
    return
  endif

  const [line_number, column_number] = fileUtil.DetectLineAndColumnInFile(filepath, line_pattern, column_pattern)
  execute command_to_edit fnameescape(filepath)
  cursorUtil.MoveIntoFolding(line_number, column_number)

  if line_number ==# 0 && column_number ==# 0
    logger.Warn($"{destination} not found in {filepath}.")
  endif
enddef

def DequeueForClassDestinations(): void
  if !empty(queue_for_class_destinations)
    const routing = remove(queue_for_class_destinations, 0)
    const tagname = matchstr(routing.destination, '\v\w+$')
    const options = { exit: (_) => timer_start(10, (_) => DequeueForClassDestinations()) }

    logger.Info($"Running `:FzfTjump` for {string(routing.line)}...")
    fzfTjump.Run(tagname, options)
  endif
enddef

plugin.EnsureSourced("fzf.vim")
plugin.EnsureSourced("vim-parallel-auto-ctags")
