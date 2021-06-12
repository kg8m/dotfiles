vim9script

const FILETYPES = ["eruby", "html", "javascript", "markdown", "typescript"]

def kg8m#plugin#closetag#configure(): void
  g:closetag_filetypes = join(FILETYPES, ",")

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: FILETYPES,
  })
enddef
