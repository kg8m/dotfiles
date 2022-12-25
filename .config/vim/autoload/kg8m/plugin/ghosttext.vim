vim9script

export def OnSource(): void
  g:dps_ghosttext#enable_autostart = false
  g:dps_ghosttext#ftmap = {
    "github.com": "markdown",
    "gitlab.com": "markdown",
    "sentry.io": "markdown",
  }
enddef
