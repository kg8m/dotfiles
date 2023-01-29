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
    {
      group: AUGROUP_NAME,
      event: "Syntax",
      pattern: join(TS_FILETYPES, ","),
      cmd: "SyntaxForTypeScript()",
    },
  ])
enddef

def SetupBuffer(): void
  setlocal iskeyword+=$
enddef

def SyntaxForTypeScript(): void
  # Extend regular expressions syntax highlighting for TypeScript by vim-javascript's syntax for JavaScript.
  # https://github.com/pangloss/vim-javascript/blob/c470ce1399a544fe587eab950f571c83cccfbbdc/syntax/javascript.vim#L64-L74
  syntax match   jsSpecial          contained "\v\\%(x\x\x|u%(\x{4}|\{\x{4,5}})|c\u|.)"
  syntax region  jsRegexpCharClass  contained start=+\[+ skip=+\\.+ end=+\]+ contains=jsSpecial extend
  syntax match   jsRegexpBoundary   contained "\v\c[$^]|\\b"
  syntax match   jsRegexpBackRef    contained "\v\\[1-9]\d*"
  syntax match   jsRegexpQuantifier contained "\v[^\\]%([?*+]|\{\d+%(,\d*)?})\??"lc=1
  syntax match   jsRegexpOr         contained "|"
  syntax match   jsRegexpMod        contained "\v\(\?[:=!>]"lc=1
  syntax region  jsRegexpGroup      contained start="[^\\]("lc=1 skip="\\.\|\[\(\\.\|[^]]\+\)\]" end=")" contains=jsRegexpCharClass,@jsRegexpSpecial keepend
  syntax region  jsRegexpString     start=+\%(\%(\<return\|\<typeof\|\_[^)\]'"[:blank:][:alnum:]_$]\)\s*\)\@<=/\ze[^*/]+ skip=+\\.\|\[[^]]\{1,}\]+ end=+/[gimyus]\{,6}+ contains=jsRegexpCharClass,jsRegexpGroup,@jsRegexpSpecial oneline keepend extend
  syntax cluster jsRegexpSpecial    contains=jsSpecial,jsRegexpBoundary,jsRegexpBackRef,jsRegexpQuantifier,jsRegexpOr,jsRegexpMod

  highlight default link jsSpecial          Special
  highlight default link jsRegexpString     String
  highlight default link jsRegexpBoundary   SpecialChar
  highlight default link jsRegexpQuantifier SpecialChar
  highlight default link jsRegexpOr         Conditional
  highlight default link jsRegexpMod        SpecialChar
  highlight default link jsRegexpBackRef    SpecialChar
  highlight default link jsRegexpGroup      jsRegexpString
  highlight default link jsRegexpCharClass  Character
enddef
