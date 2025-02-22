vim9script

var timer = -1

export def Setup(): void
  augroup vimrc-util-dim_inactive_windows
    autocmd!
    autocmd WinEnter        * Trigger()
    autocmd SessionLoadPost * Trigger()
    autocmd VimResized      * Trigger()
  augroup END
enddef

export def Reset()
  bufdo if IsOriginalColorcolumnStored() | RestoreOriginalColorcolumn() | endif
enddef

def Trigger(): void
  timer_stop(timer)
  timer = timer_start(50, (_) => Apply())
enddef

def Apply(): void
  const current_winnr = winnr()
  const last_winnr    = winnr("$")
  const colorcolumns  = range(1, &columns)->join(",")

  for winnr in range(1, last_winnr)
    if ShouldSkipWindow(winnr)
      if IsOriginalColorcolumnStored(winnr)
        RestoreOriginalColorcolumn(winnr)
      endif

      continue
    endif

    if winnr ==# current_winnr
      if IsOriginalColorcolumnStored(winnr)
        RestoreOriginalColorcolumn(winnr)
      endif
    else
      if !IsOriginalColorcolumnStored(winnr)
        StoreOriginalColorcolumn(winnr)
      endif

      SetColorcolumn(winnr, colorcolumns)
    endif
  endfor
enddef

def ShouldSkipWindow(winnr: number): bool
  return (
    # Skip diff windows because colorcolumn hides diff colors.
    getwinvar(winnr, "&diff") ||

    # Skip Git commit buffer because colorcolumn hides diff colors.
    getwinvar(winnr, "&filetype") ==# "gitcommit"
  )
enddef

def SetColorcolumn(winnr: number, value: string): void
  setwinvar(winnr, "&colorcolumn", value)
enddef

def SetOriginalColorcolumn(winnr: number, value: any): void
  # Store original_colorcolumn value in bufvar because sometimes winvars are removed for some reason.
  setbufvar(winbufnr(winnr), "original_colorcolumn", value)
enddef

def GetOriginalColorcolumn(winnr: number): any
  return getbufvar(winbufnr(winnr), "original_colorcolumn", v:null)
enddef

def StoreOriginalColorcolumn(winnr: number): void
  SetOriginalColorcolumn(winnr, getwinvar(winnr, "&colorcolumn"))
enddef

def RestoreOriginalColorcolumn(winnr: number = winnr()): void
  SetColorcolumn(winnr, GetOriginalColorcolumn(winnr))
enddef

def IsOriginalColorcolumnStored(winnr: number = winnr()): bool
  return GetOriginalColorcolumn(winnr) !=# v:null
enddef
