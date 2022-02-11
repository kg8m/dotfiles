vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: "qf",
    hook_source: () => OnSource(),
  })
enddef

def OnSource(): void
  g:qfenter_keymap = {
    open: ["<CR>"],

    # Disable other mappings.
    vopen: [], hopen: [], topen: [],
  }

  # default: "##cc"
  # zv: Show cursor even if in fold.
  # zz: Adjust cursor at center of window.
  g:qfenter_cc_cmd = "##cc | normal! zvzz"
enddef
