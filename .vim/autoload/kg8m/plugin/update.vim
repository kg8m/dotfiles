vim9script

def kg8m#plugin#update#run(options: dict<any> = {}): void
  timer_start(   0, (_) => s:_run(options) )
  timer_start( 200, (_) => s:remove_disused())
  timer_start(1000, (_) => kg8m#plugin#update#show_log())
enddef

def kg8m#plugin#update#show_log(): void
  const initial_input =
    '!Same\\ revision'
    .. '\ !Current\\ branch\\ *\\ is\\ up\\ to\\ date.'
    .. '\ !^$'
    .. '\ !(*/*)\\ [+'
    .. '\ !(*/*)\\ [-'
    .. '\ !Created\\ autostash'
    .. '\ !Applied\\ autostash'
    .. '\ !HEAD\\ is\\ now'
    .. '\ !\\ *->\\ origin/'
    .. '\ !^First,\\ rewinding\\ head\\ to\\ replay\\ your\\ work\\ on\\ top\\ of\\ it'
    .. '\ !^Fast-forwarded\\ *\\ to'
    .. '\ !^From\\ https://'
    .. '\ !^Already\\ up\\ to\\ date.$'
    .. '\ !Successfully\\ rebased\\ and\\ updated\\ refs/heads/'
    .. '\ !*\\ [new\\ tag]'
    .. '\ !already\\ exists,\\ disabling\\ multiplexing'
    .. '\ !refs/remotes/origin/HEAD\\ has\\ become\\ dangling'
    .. '\ !origin/HEAD\\ set\\ to'
    .. '\ !Your\\ configuration\\ specifies\\ to\\ merge\\ with\\ the\\ ref'
    .. '\ !from\\ the\\ remote,\\ but\\ no\\ such\\ ref\\ was\\ fetched.'
    .. '\ !git\\ -c\\ credential.helper'

  execute "Unite dein/log -buffer-name=update_plugins -input=" .. initial_input

  # Press `n` key to search.
  @/ = "\\v<(Error|Updated)>"
enddef

def s:_run(options: dict<any> = {}): void
  # Clear messages because they will be used in `s:check_finished`
  messages clear

  # Re-register disabled plugins before update because dein.vim doesn't make helptags for them
  kg8m#plugin#enable_disabled_plugins()

  if get(options, "bulk", true)
    const force_update = true
    dein#check_update(force_update)
  else
    dein#update()
  endif

  s:check_finished()
enddef

def s:remove_disused(): void
  for dirpath in dein#check_clean()
    kg8m#util#logger#warn("Remove " .. dirpath)
    delete(dirpath, "rf")
  endfor
enddef

def s:check_finished(options: dict<any> = {}): void
  final options_cache = copy(options)

  if !has_key(options_cache, "start_time")
    options_cache.start_time = localtime()
  endif

  if execute("messages") =~# '\v\[dein\] Done:'
    const should_stay = (localtime() - options_cache.start_time) > 30
    s:notify("Finished.", { stay: should_stay })
  else
    const progress      = dein#install#_get_progress()
    const prev_progress = get(options_cache, "prev_progress", v:null)
    var   retry_count   = get(options_cache, "retry_count", 0)

    # Clear echo messages because they are noisy if multi-line
    redraw

    # Respect dein.vim's original message
    echo "[dein] " .. progress

    if progress ==# prev_progress
      retry_count += 1

      if retry_count > 100
        s:notify("Something is wrong.", { stay: true, level: "error" })
        return
      endif
    else
      retry_count = 0
    endif

    options_cache.prev_progress = progress
    options_cache.retry_count   = retry_count
    timer_start(300, (_) => s:check_finished(options_cache))
  endif
enddef

def s:notify(message: string, options: dict<any> = {}): void
  const is_stay = get(options, "stay", false)
  const level   = get(options, "level", "warn")

  const hostname = system("hostname")->trim()
  const title    = "Updating Vim plugins"

  final notify_command = [
    "/usr/local/bin/terminal-notifier",
    "-title", title,
    "-message", "\\[" .. hostname .. "] " .. message,
    "-group", "UPDATING_VIM_PLUGINS_FINISHED_" .. hostname,
  ]

  if is_stay
    extend(notify_command, ["-sender", "TERMINAL_NOTIFIER_STAY"])
  endif

  notify_command->map((_, command) => shellescape(command))
  job_start(["ssh", "main", "-t", notify_command->join(" ")])

  const message_with_title = title .. ": " .. message

  if level ==# "warn"
    kg8m#util#logger#warn(message_with_title)
  else
    kg8m#util#logger#error(message_with_title)
  endif
enddef
