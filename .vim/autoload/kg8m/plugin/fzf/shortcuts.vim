vim9script

kg8m#plugin#ensure_sourced("fzf.vim")

var s:raw_list: list<list<string>>
var s:list: list<string>
var s:max_label_length: number
var s:is_initialized = false

def kg8m#plugin#fzf#shortcuts#run(query: string): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(),
    sink:    function("s:handler"),
    options: ["--no-multi", "--prompt", "Shortcuts> ", "--query", query],
  }

  kg8m#plugin#fzf#run(() => fzf#run(fzf#wrap("my-shortcuts", options)))
enddef

def s:candidates(): list<string>
  s:setup_list()
  return s:list
enddef

def s:handler(item: string): void
  # Don't `execute substitute(...)` because it causes problem if the command is Fzf's
  const command = substitute(item, '\v.*--\s+`(.+)`$', '\1', "")
  feedkeys(":" .. command .. "\<CR>")
enddef

def s:setup_list(): void
  if s:is_initialized
    return
  endif

  s:define_raw_list()
  s:count_max_label_length()
  s:make_groups()
  s:format_list()

  s:is_initialized = true
enddef

def s:define_raw_list(): void
  # Hankaku/Zenkaku: http://nanasi.jp/articles/vim/hz_ja_vim.html
  s:raw_list = [
    ["[Hankaku/Zenkaku] All to Hankaku",           "'<,'>Hankaku"],
    ["[Hankaku/Zenkaku] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
    ["[Hankaku/Zenkaku] ASCII to Hankaku",         "'<,'>HzjaConvert han_ascii"],
    ["[Hankaku/Zenkaku] All to Zenkaku",           "'<,'>Zenkaku"],
    ["[Hankaku/Zenkaku] Kana to Zenkaku",          "'<,'>HzjaConvert zen_kana"],

    ["[Reload with Encoding] latin1",      "call kg8m#util#encoding#edit_with_latin1(#{ force: v:true })"],
    ["[Reload with Encoding] cp932",       "call kg8m#util#encoding#edit_with_cp932(#{ force: v:true })"],
    ["[Reload with Encoding] shift-jis",   "call kg8m#util#encoding#edit_with_shiftjis(#{ force: v:true })"],
    ["[Reload with Encoding] iso-2022-jp", "call kg8m#util#encoding#edit_with_iso2022jp(#{ force: v:true })"],
    ["[Reload with Encoding] euc-jp",      "call kg8m#util#encoding#edit_with_eucjp(#{ force: v:true })"],
    ["[Reload with Encoding] utf-8",       "call kg8m#util#encoding#edit_with_utf8(#{ force: v:true })"],

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

    ["[Copy] filename",                       "call kg8m#util#remote_copy(kg8m#util#file#current_name())"],
    ["[Copy] relative filepath",              "call kg8m#util#remote_copy(kg8m#util#file#current_relative_path())"],
    ["[Copy] absolute filepath",              "call kg8m#util#remote_copy(kg8m#util#file#current_absolute_path())"],
    ["[Copy][Ruby] nested class/module name", "call kg8m#util#filetypes#ruby#copy_nested_class_name()"],

    ["[Git] Gina patch",                                 "call kg8m#plugin#gina#patch(expand(\"%\"))"],
    ["[Git] Apply the patch/hunk to the another side",   "'<,'>diffput"],
    ["[Git] Apply the patch/hunk from the another side", "'<,'>diffget"],

    ["[Ruby] Hash Syntax: Old to new", "'<,'>s/\\v([^:]):([a-zA-Z0-9_\"']+)( *)\\=\\> /\\1\\2:\\3/g"],
    ["[Ruby] Hash Syntax: New to old", "'<,'>s/\\v([a-zA-Z0-9_\"']+):( *) /:\\1\\2 => /g"],

    ["[Outline][Ruby][RSpec] Show Outline", "call kg8m#plugin#fzf#rspec#outline()"],

    ["[SimpleAlign] \"=\"",          "'<,'>SimpleAlign = -count 1"],
    ["[SimpleAlign] \"=>\"",         "'<,'>SimpleAlign => -count 1"],
    ["[SimpleAlign] \"+=\"",         "'<,'>SimpleAlign [\\ +]= -count 1"],
    ["[SimpleAlign] /\\S/",          "'<,'>SimpleAlign \\S\\+ -lpadding 0"],
    ["[SimpleAlign] /\\S/ once",     "'<,'>SimpleAlign \\S\\+ -lpadding 0 -count 1"],
    ["[SimpleAlign] /\\S/ twice",    "'<,'>SimpleAlign \\S\\+ -lpadding 0 -count 2"],
    ["[SimpleAlign] \":foo\"",       "'<,'>SimpleAlign : -rpadding 0"],
    ["[SimpleAlign] \"foo:\"",       "'<,'>SimpleAlign [^:\\ ]\\+:"],
    ["[SimpleAlign] \"foo:\" once",  "'<,'>SimpleAlign [^:\\ ]\\+: -count 1"],
    ["[SimpleAlign] \"foo:\" twice", "'<,'>SimpleAlign [^:\\ ]\\+: -count 2"],
    ["[SimpleAlign] \"|\"",          "'<,'>SimpleAlign |"],
    ["[SimpleAlign] \")\"",          "'<,'>SimpleAlign ) -lpadding 0"],
    ["[SimpleAlign] \"]\"",          "'<,'>SimpleAlign ] -lpadding 0"],
    ["[SimpleAlign] \"}\"",          "'<,'>SimpleAlign }"],
    ["[SimpleAlign] \"  # \"",       "'<,'>SimpleAlign # -lpadding 2"],
    ["[SimpleAlign] \"  // \"",      "'<,'>SimpleAlign // -lpadding 2"],
    ["[SimpleAlign] \"  #=> \"",     "'<,'>SimpleAlign #=> -lpadding 2"],
    ["[SimpleAlign] \"  //=> \"",    "'<,'>SimpleAlign //=> -lpadding 2"],

    ["[LSP] CodeAction",                  "LspCodeAction"],
    ["[LSP] CodeAction: organizeImports", "LspCodeAction source.organizeImports"],

    ["[Autoformat] Format Source Codes", "Autoformat"],

    ["[Diff] Linediff", "'<,'>Linediff"],

    ["[QuickFix] Replace", "Qfreplace"],
  ]
enddef

def s:count_max_label_length(): void
  s:max_label_length = s:raw_list->mapnew((_, item) => s:item_label_length(item[0]))->max()
enddef

def s:item_label_length(item_label: string): number
  return item_label->strlen()
enddef

def s:make_groups(): void
  var prev_prefix = ""
  final new_list = []

  for candidate in s:raw_list
    const current_prefix = s:group_name(candidate[0])

    if !empty(new_list) && current_prefix !=# prev_prefix
      add(new_list, ["", ""])
    endif

    add(new_list, candidate)
    prev_prefix = current_prefix
  endfor

  s:raw_list = new_list
enddef

def s:group_name(item: string): string
  return matchstr(item, '\v^\[[^]]+\]')
enddef

def s:format_list(): void
  s:list = s:raw_list->mapnew((_, item) => s:format_item(item))
enddef

def s:format_item(item: list<string>): string
  const description = item[0]
  const command     = item[1]

  if empty(description)
    return ""
  else
    return description .. s:word_padding(description) .. "  --  `" .. command .. "`"
  endif
enddef

def s:word_padding(item: string): string
  return repeat(" ", s:max_label_length - strlen(item))
enddef
