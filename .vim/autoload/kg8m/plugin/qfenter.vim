vim9script

def kg8m#plugin#qfenter#configure(): void
  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "qf",
    hook_source: () => s:on_source(),
  })
enddef

def s:on_source(): void
  g:qfenter_keymap = {
    open: ["<CR>"],

    # Disable other mappings.
    vopen: [], hopen: [], topen: [],
  }
enddef
