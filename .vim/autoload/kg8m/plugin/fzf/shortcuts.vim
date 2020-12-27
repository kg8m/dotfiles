vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

var s:raw_list: list<list<string>>
var s:list: list<string>
var s:max_label_length: number
var s:is_initialized = false

def kg8m#plugin#fzf#shortcuts#run(query: string): void  # {{{
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    "source":  s:candidates(),
    "sink":    function("s:handler"),
    "options": ["--no-multi", "--prompt", "Shortcuts> ", "--query", query],
  }

  fzf#run(fzf#wrap("my-shortcuts", options))
enddef  # }}}

def s:candidates(): list<string>  # {{{
  s:setup_list()
  return s:list
enddef  # }}}

def s:handler(item: string): void  # {{{
  # Don't `execute substitute(...)` because it causes problem if the command is Fzf's
  const command = substitute(item, '\v.*--\s+`(.+)`$', '\1', "")
  feedkeys(":" .. command .. "\<CR>")
enddef  # }}}

def s:setup_list(): void  # {{{
  if s:is_initialized
    return
  endif

  s:define_raw_list()
  s:count_max_label_length()
  s:make_groups()
  s:format_list()

  s:is_initialized = true
enddef  # }}}

def s:define_raw_list(): void  # {{{
  # Hankaku/Zenkaku: http://nanasi.jp/articles/vim/hz_ja_vim.html
  s:raw_list = [
    ["[Hankaku/Zenkaku] All to Hankaku",           "'<,'>Hankaku"],
    ["[Hankaku/Zenkaku] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
    ["[Hankaku/Zenkaku] ASCII to Hankaku",         "'<,'>HzjaConvert han_ascii"],
    ["[Hankaku/Zenkaku] All to Zenkaku",           "'<,'>Zenkaku"],
    ["[Hankaku/Zenkaku] Kana to Zenkaku",          "'<,'>HzjaConvert zen_kana"],

    ["[Reload with Encoding] latin1",      "edit ++encoding=latin1 +set\\ noreadonly"],
    ["[Reload with Encoding] cp932",       "edit ++encoding=cp932 +set\\ noreadonly"],
    ["[Reload with Encoding] shift-jis",   "edit ++encoding=shift-jis +set\\ noreadonly"],
    ["[Reload with Encoding] iso-2022-jp", "edit ++encoding=iso-2022-jp +set\\ noreadonly"],
    ["[Reload with Encoding] euc-jp",      "edit ++encoding=euc-jp +set\\ noreadonly"],
    ["[Reload with Encoding] utf-8",       "edit ++encoding=utf-8 +set\\ noreadonly"],

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

    ["[Copy] filename",          "call kg8m#util#remote_copy(kg8m#util#current_filename())"],
    ["[Copy] relative filepath", "call kg8m#util#remote_copy(kg8m#util#current_relative_path())"],
    ["[Copy] absolute filepath", "call kg8m#util#remote_copy(kg8m#util#current_absolute_path())"],

    ["[Git] Gina patch",                                 "call kg8m#plugin#gina#patch(expand(\"%\"))"],
    ["[Git] Apply the patch/hunk to the another side",   "'<,'>diffput"],
    ["[Git] Apply the patch/hunk from the another side", "'<,'>diffget"],

    ["[Ruby Hash Syntax] Old to New", "'<,'>s/\\v([^:]):(\\w+)( *)\\=\\> /\\1\\2:\\3/g"],
    ["[Ruby Hash Syntax] New to Old", "'<,'>s/\\v(\\w+):( *) /:\\1\\2 => /g"],

    ["[EasyAlign] '='",                  "'<,'>EasyAlign ="],
    ["[EasyAlign] '=>'",                 "'<,'>EasyAlign =>"],
    ["[EasyAlign] ' '",                  "'<,'>EasyAlign \\"],
    ["[EasyAlign] ' ' repeated",         "'<,'>EasyAlign *\\"],
    ["[EasyAlign] 'hoge:'",              "'<,'>EasyAlign :"],
    ["[EasyAlign] '|' repeated (table)", "'<,'>EasyAlign *|"],

    ["[Autoformat] Format Source Codes", "Autoformat"],

    ["[Diff] Linediff", "'<,'>Linediff"],

    ["[QuickFix] Replace", "Qfreplace"],
  ]
enddef  # }}}

def s:count_max_label_length(): void  # {{{
  s:max_label_length =
    s:raw_list
      ->copy()
      ->map("s:item_label_length(v:val[0])")
      ->max()
enddef  # }}}

def s:item_label_length(item_label: string): number  # {{{
  return item_label->strlen()
enddef  # }}}

def s:make_groups(): void  # {{{
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
enddef  # }}}

def s:group_name(item: string): string  # {{{
  return matchstr(item, '\v^\[[^]]+\]')
enddef  # }}}

def s:format_list(): void  # {{{
  s:list = s:raw_list->copy()->map("s:format_item(v:val)")
enddef  # }}}

def s:format_item(item: list<string>): string  # {{{
  const description = item[0]
  const command     = item[1]

  if empty(description)
    return ""
  else
    return description .. s:word_padding(description) .. "  --  `" .. command .. "`"
  endif
enddef  # }}}

def s:word_padding(item: string): string  # {{{
  return repeat(" ", s:max_label_length - strlen(item))
enddef  # }}}
