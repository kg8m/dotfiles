vim9script

def kg8m#plugin#helpful#configure(): void
  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "HelpfulVersion",
  })
enddef
