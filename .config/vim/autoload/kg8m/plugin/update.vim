vim9script

export def Run(options: dict<any> = {}): void
  timer_start(   0, (_) => Main(options) )
  timer_start( 200, (_) => RemoveDisused())
  timer_start(1000, (_) => kg8m#plugin#update#ShowLog())
enddef

export def ShowLog(): void
  const initial_input =
    '!Same\\ revision'
    .. '\ !Current\\ branch\\ *\\ is\\ up\\ to\\ date.'
    .. '\ !^$'
    .. '\ !(*/*)\\ [+'
    .. '\ !(*/*)\\ [-'
    .. '\ !:\\ pushed_time='
    .. '\ !:\\ remote='
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

  execute $"Unite dein/log -buffer-name=update_plugins -input={initial_input}"

  # Press `n` key to search.
  @/ = "\\v<(Error|Updated)>"
enddef

def Main(options: dict<any> = {}): void
  # Clear messages because they will be used in `CheckFinished()`.
  messages clear

  # Re-register disabled plugins before update because dein.vim doesn't make helptags for them
  kg8m#plugin#EnableDisabledPlugins()

  if get(options, "bulk", true)
    const force_update = true
    dein#check_update(force_update)
  else
    dein#update()
  endif

  CheckFinished()
enddef

def RemoveDisused(): void
  for dirpath in dein#check_clean()
    kg8m#util#logger#Warn($"Remove {dirpath}")
    delete(dirpath, "rf")
  endfor
enddef

def CheckFinished(options: dict<any> = {}): void
  final options_cache = copy(options)

  if !has_key(options_cache, "start_time")
    options_cache.start_time = localtime()
  endif

  if execute("messages") =~# '\v\[dein\] Done:'
    const should_stay = (localtime() - options_cache.start_time) > 30
    Notify("Finished.", { stay: should_stay })
  else
    const progress      = dein#install#_get_progress()
    const prev_progress = get(options_cache, "prev_progress", v:null)
    var   retry_count   = get(options_cache, "retry_count", 0)

    # Clear echo messages because they are noisy if multi-line
    redraw

    # Respect dein.vim's original message
    echo $"[dein] {progress}"

    if progress ==# prev_progress
      retry_count += 1

      if retry_count > 100
        Notify("Something is wrong.", { stay: true, level: "error" })
        return
      endif
    else
      retry_count = 0
    endif

    options_cache.prev_progress = progress
    options_cache.retry_count   = retry_count
    timer_start(300, (_) => CheckFinished(options_cache))
  endif
enddef

def Notify(message: string, options: dict<any> = {}): void
  const is_stay = get(options, "stay", false)
  const level   = get(options, "level", "info")

  const hostname = system("hostname")->trim()
  const title    = "Updating Vim plugins"

  final notify_command = [
    "notify",
    "--title", title,
    message,
  ]

  if !is_stay
    extend(notify_command, ["--nostay"])
  endif

  notify_command->map((_, command) => shellescape(command))
  system(notify_command->join(" "))

  const message_with_title = $"{title}: {message}"

  if level ==# "info"
    kg8m#util#logger#Info(message_with_title)
  elseif level ==# "warn"
    kg8m#util#logger#Warn(message_with_title)
  elseif level ==# "error"
    kg8m#util#logger#Error(message_with_title)
  else
    kg8m#util#logger#Error($"{title}: unknown level ({string(level)})")
    kg8m#util#logger#Info(message_with_title)
  endif
enddef
