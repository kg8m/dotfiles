vim9script

export const JS_FILETYPES = ["javascript", "javascriptreact"]
export const TS_FILETYPES = ["typescript", "typescriptreact"]

const AUGROUP_NAME = "vimrc-configure-filetypes-javascript"

export def Run(): void
  execute $"augroup {AUGROUP_NAME}"
    autocmd!
  augroup END

  autocmd_add([
    {
      group: AUGROUP_NAME,
      event: "FileType",
      pattern: join(JS_FILETYPES + TS_FILETYPES, ","),
      cmd: "SetupBuffer()",
    },
  ])
enddef

def SetupBuffer(): void
  setlocal iskeyword+=$
enddef
