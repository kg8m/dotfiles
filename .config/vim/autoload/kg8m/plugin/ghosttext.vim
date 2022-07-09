vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  ["GhostStart"],
    depends: ["denops.vim"],
    hook_source: () => OnSource(),
  })
enddef

def OnSource(): void
  g:dps_ghosttext#enable_autostart = false
  g:dps_ghosttext#ftmap = {
    "github.com": "markdown",
    "gitlab.com": "markdown",
    "sentry.io": "markdown",
  }
enddef
