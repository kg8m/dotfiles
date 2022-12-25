vim9script

export def Run(): void
  kg8m#plugin#EnsureSourced("vim-checkbox")
  checkbox#ToggleCB()
enddef
