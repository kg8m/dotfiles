vim9script

export def OnSource(): void
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
