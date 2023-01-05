vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/plugin/fzf.vim"

plugin.EnsureSourced("fzf.vim")

var raw_list: list<list<string>>
var list: list<string>
var max_label_length: number

export def Run(query: string): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  Candidates(),
    sink:    Handler,
    options: ["--no-multi", "--prompt", "Shortcuts> ", "--query", query],
  }

  fzf.Run(() => fzf#run(fzf#wrap("my-shortcuts", options)))
enddef

def Candidates(): list<string>
  return list
enddef

def Handler(item: string): void
  const command = substitute(item, '\v.*--\s+`(.+)`$', '\1', "")

  # Use `feedkeys` instead of `execute` because `execute` doesn't work if the command uses fzf.
  feedkeys($":{command}\<CR>")
enddef

def SetupList(): void
  DefineRawList()
  CountMaxLabelLength()
  MakeGroups()
  FormatList()
enddef

def DefineRawList(): void
  # Hankaku/Zenkaku: http://nanasi.jp/articles/vim/hz_ja_vim.html
  raw_list = [
    ["[Hankaku/Zenkaku] All to Hankaku",           "'<,'>Hankaku"],
    ["[Hankaku/Zenkaku] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
    ["[Hankaku/Zenkaku] ASCII to Hankaku",         "'<,'>HzjaConvert han_ascii"],
    ["[Hankaku/Zenkaku] All to Zenkaku",           "'<,'>Zenkaku"],
    ["[Hankaku/Zenkaku] Kana to Zenkaku",          "'<,'>HzjaConvert zen_kana"],

    ["[Reload with Encoding] latin1",      "call kg8m#util#encoding#EditWithLatin1(#{ force: v:true })"],
    ["[Reload with Encoding] CP932",       "call kg8m#util#encoding#EditWithCP932(#{ force: v:true })"],
    ["[Reload with Encoding] Shift_JIS",   "call kg8m#util#encoding#EditWithShiftJIS(#{ force: v:true })"],
    ["[Reload with Encoding] ISO-2022-JP", "call kg8m#util#encoding#EditWithISO2022JP(#{ force: v:true })"],
    ["[Reload with Encoding] EUC-JP",      "call kg8m#util#encoding#EditWithEUCJP(#{ force: v:true })"],
    ["[Reload with Encoding] UTF-8",       "call kg8m#util#encoding#EditWithUTF8(#{ force: v:true })"],

    ["[Reload by Sudo]",     "SudaRead"],
    ["[Write/save by Sudo]", "SudaWrite"],

    ["[Set Encoding] latin1",      "set fileencoding=latin1"],
    ["[Set Encoding] cp932",       "set fileencoding=cp932"],
    ["[Set Encoding] shift-jis",   "set fileencoding=shift-jis"],
    ["[Set Encoding] iso-2022-jp", "set fileencoding=iso-2022-jp"],
    ["[Set Encoding] euc-jp",      "set fileencoding=euc-jp"],
    ["[Set Encoding] utf-8",       "set fileencoding=utf-8"],

    ["[Set File Format] dos",  "set fileformat=dos"],
    ["[Set File Format] unix", "set fileformat=unix"],
    ["[Set File Format] mac",  "set fileformat=mac"],

    ["[Copy] filename",                       "call kg8m#util#RemoteCopy(kg8m#util#file#CurrentName())"],
    ["[Copy] relative filepath",              "call kg8m#util#RemoteCopy(kg8m#util#file#CurrentRelativePath())"],
    ["[Copy] absolute filepath",              "call kg8m#util#RemoteCopy(kg8m#util#file#CurrentAbsolutePath())"],
    ["[Copy][Ruby] nested class/module name", "call kg8m#util#filetypes#ruby#CopyNestedNamespace()"],

    ["[Git] GinEdit",                                    "call kg8m#plugin#gin#Edit()"],
    ["[Git] GinPatch",                                   "call kg8m#plugin#gin#Patch()"],
    ["[Git] Apply the patch/hunk to the another side",   "'<,'>diffput"],
    ["[Git] Apply the patch/hunk from the another side", "'<,'>diffget"],

    ["[Ruby] Hash Syntax: Old to new", "'<,'>s/\\v([^:]):([a-zA-Z0-9_\"']+)( *)\\=\\> /\\1\\2:\\3/g"],
    ["[Ruby] Hash Syntax: New to old", "'<,'>s/\\v([a-zA-Z0-9_\"']+):( *) /:\\1\\2 => /g"],

    ["[Outline][Ruby][RSpec] Show Outline", "call kg8m#plugin#fzf#outline#Rspec()"],

    ["[Vim] Get syntax group name", "PP synIDattr(synID(line('.'), col('.'), 1), 'name')"],

    ["[SimpleAlign] \"=\"",          "'<,'>SimpleAlign = -count 1"],
    ["[SimpleAlign] \"=>\"",         "'<,'>SimpleAlign => -count 1"],
    ["[SimpleAlign] \"+=\"",         "'<,'>SimpleAlign [\\ +]= -count 1"],
    ["[SimpleAlign] /\\S/",          "'<,'>SimpleAlign \\S\\+ -lpadding 0"],
    ["[SimpleAlign] /\\S/ once",     "'<,'>SimpleAlign \\S\\+ -lpadding 0 -count 1"],
    ["[SimpleAlign] /\\S/ twice",    "'<,'>SimpleAlign \\S\\+ -lpadding 0 -count 2"],
    ["[SimpleAlign] \":foo\"",       "'<,'>SimpleAlign : -rpadding 0"],
    ["[SimpleAlign] \"foo:\"",       "'<,'>SimpleAlign [^:\\ ]\\+:\\(:\\)\\@!"],
    ["[SimpleAlign] \"foo:\" once",  "'<,'>SimpleAlign [^:\\ ]\\+:\\(:\\)\\@! -count 1"],
    ["[SimpleAlign] \"foo:\" twice", "'<,'>SimpleAlign [^:\\ ]\\+:\\(:\\)\\@! -count 2"],
    ["[SimpleAlign] \"|\"",          "'<,'>SimpleAlign |"],
    ["[SimpleAlign] \")\"",          "'<,'>SimpleAlign ) -lpadding 0"],
    ["[SimpleAlign] \"]\"",          "'<,'>SimpleAlign ] -lpadding 0"],
    ["[SimpleAlign] \"}\"",          "'<,'>SimpleAlign }"],
    ["[SimpleAlign] \"  # \"",       "'<,'>SimpleAlign # -lpadding 2"],
    ["[SimpleAlign] \"  // \"",      "'<,'>SimpleAlign // -lpadding 2"],
    ["[SimpleAlign] \"  #=> \"",     "'<,'>SimpleAlign #=> -lpadding 2"],
    ["[SimpleAlign] \"  //=> \"",    "'<,'>SimpleAlign //=> -lpadding 2"],

    ["[LSP] CodeAction",                   "LspCodeAction"],
    ["[LSP] CodeAction: organizeImports",  "LspCodeAction source.organizeImports"],
    ["[LSP] Enforce automatic formatting", "call kg8m#plugin#lsp#document_format#EnforceAutoFormatting()"],

    ["[Diff] Linediff", "'<,'>Linediff"],
  ]
enddef

def CountMaxLabelLength(): void
  max_label_length = raw_list->mapnew((_, item) => ItemLabelLength(item[0]))->max()
enddef

def ItemLabelLength(item_label: string): number
  return item_label->strlen()
enddef

def MakeGroups(): void
  var prev_prefix = ""
  final new_list = []

  for candidate in raw_list
    const current_prefix = GroupName(candidate[0])

    if !empty(new_list) && current_prefix !=# prev_prefix
      add(new_list, ["", ""])
    endif

    add(new_list, candidate)
    prev_prefix = current_prefix
  endfor

  raw_list = new_list
enddef

def GroupName(item: string): string
  return matchstr(item, '\v^\[[^]]+\]')
enddef

def FormatList(): void
  list = raw_list->mapnew((_, item) => FormatItem(item))
enddef

def FormatItem(item: list<string>): string
  const [description, command] = item

  if empty(description)
    return ""
  else
    return $"{description}{WordPadding(description)}  --  `{command}`"
  endif
enddef

def WordPadding(item: string): string
  return repeat(" ", max_label_length - strlen(item))
enddef

SetupList()
