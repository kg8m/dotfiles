function kg8m#plugin#fzf#shortcuts#run(query) abort  " {{{
  let options = {
  \   "source":  s:candidates(),
  \   "sink":    function("s:handler"),
  \   "options": ["--no-multi", "--prompt", "Shortcuts> ", "--query", a:query],
  \ }

  call fzf#run(fzf#wrap("my-shortcuts", options))
endfunction  " }}}

function s:candidates() abort  " {{{
  call s:setup_list()
  return s:list
endfunction  " }}}

function s:handler(item) abort  " {{{
  " Don't call `execute substitute(...)` because it causes problem if the command is Fzf's
  let command = substitute(a:item, '\v.*--\s+`(.+)`$', '\1', "")
  call feedkeys(":"..command.."\<Cr>")
endfunction  " }}}

function s:setup_list() abort  " {{{
  if has_key(s:, "list")
    return
  endif

  call s:define_raw_list()
  call s:count_max_label_length()
  call s:make_groups()
  call s:format_list()
endfunction  " }}}

function s:define_raw_list() abort  " {{{
  " Hankaku/Zenkaku: http://nanasi.jp/articles/vim/hz_ja_vim.html
  let s:list = [
  \   ["[Hankaku/Zenkaku] All to Hankaku",           "'<,'>Hankaku"],
  \   ["[Hankaku/Zenkaku] Alphanumerics to Hankaku", "'<,'>HzjaConvert han_eisu"],
  \   ["[Hankaku/Zenkaku] ASCII to Hankaku",         "'<,'>HzjaConvert han_ascii"],
  \   ["[Hankaku/Zenkaku] All to Zenkaku",           "'<,'>Zenkaku"],
  \   ["[Hankaku/Zenkaku] Kana to Zenkaku",          "'<,'>HzjaConvert zen_kana"],
  \
  \   ["[Reload with Encoding] latin1",      "edit ++encoding=latin1 +set\\ noreadonly"],
  \   ["[Reload with Encoding] cp932",       "edit ++encoding=cp932 +set\\ noreadonly"],
  \   ["[Reload with Encoding] shift-jis",   "edit ++encoding=shift-jis +set\\ noreadonly"],
  \   ["[Reload with Encoding] iso-2022-jp", "edit ++encoding=iso-2022-jp +set\\ noreadonly"],
  \   ["[Reload with Encoding] euc-jp",      "edit ++encoding=euc-jp +set\\ noreadonly"],
  \   ["[Reload with Encoding] utf-8",       "edit ++encoding=utf-8 +set\\ noreadonly"],
  \
  \   ["[Reload by Sudo]",     "SudaRead"],
  \   ["[Write/save by Sudo]", "SudaWrite"],
  \
  \   ["[Set Encoding] latin1",      "set fileencoding=latin1"],
  \   ["[Set Encoding] cp932",       "set fileencoding=cp932"],
  \   ["[Set Encoding] shift-jis",   "set fileencoding=shift-jis"],
  \   ["[Set Encoding] iso-2022-jp", "set fileencoding=iso-2022-jp"],
  \   ["[Set Encoding] euc-jp",      "set fileencoding=euc-jp"],
  \   ["[Set Encoding] utf-8",       "set fileencoding=utf-8"],
  \
  \   ["[Set File Format] dos",  "set fileformat=dos"],
  \   ["[Set File Format] unix", "set fileformat=unix"],
  \   ["[Set File Format] mac",  "set fileformat=mac"],
  \
  \   ["[Copy] filename",          "call kg8m#util#remote_copy(kg8m#util#current_filename())"],
  \   ["[Copy] relative filepath", "call kg8m#util#remote_copy(kg8m#util#current_relative_path())"],
  \   ["[Copy] absolute filepath", "call kg8m#util#remote_copy(kg8m#util#current_absolute_path())"],
  \
  \   ["[Git] Gina patch",                                 "call kg8m#plugin#gina#patch(expand(\"%\"))"],
  \   ["[Git] Apply the patch/hunk to the another side",   "'<,'>diffput"],
  \   ["[Git] Apply the patch/hunk from the another side", "'<,'>diffget"],
  \
  \   ["[Ruby Hash Syntax] Old to New", "'<,'>s/\\v([^:]):(\\w+)( *)\\=\\> /\\1\\2:\\3/g"],
  \   ["[Ruby Hash Syntax] New to Old", "'<,'>s/\\v(\\w+):( *) /:\\1\\2 => /g"],
  \
  \   ["[EasyAlign] '='",                  "'<,'>EasyAlign ="],
  \   ["[EasyAlign] '=>'",                 "'<,'>EasyAlign =>"],
  \   ["[EasyAlign] ' '",                  "'<,'>EasyAlign \\"],
  \   ["[EasyAlign] ' ' repeated",         "'<,'>EasyAlign *\\"],
  \   ["[EasyAlign] 'hoge:'",              "'<,'>EasyAlign :"],
  \   ["[EasyAlign] '|' repeated (table)", "'<,'>EasyAlign *|"],
  \
  \   ["[Autoformat] Format Source Codes", "Autoformat"],
  \
  \   ["[Diff] Linediff", "'<,'>Linediff"],
  \
  \   ["[QuickFix] Replace", "Qfreplace"],
  \ ]
endfunction  " }}}

function s:count_max_label_length() abort  " {{{
  let s:max_label_length =
  \   s:list
  \     ->copy()
  \     ->map({ _, item -> item[0]->strlen() })
  \     ->max()
endfunction  " }}}

function s:make_groups() abort  " {{{
  let prev_prefix = ""
  let new_list    = []

  for candidate in s:list
    let current_prefix = s:group_name(candidate[0])

    if !empty(new_list) && current_prefix !=# prev_prefix
      call add(new_list, ["", ""])
    endif

    call add(new_list, candidate)
    let prev_prefix = current_prefix
  endfor

  let s:list = new_list
endfunction  " }}}

function s:group_name(item) abort  " {{{
  return matchstr(a:item, '\v^\[[^]]+\]')
endfunction  " }}}

function s:format_list() abort  " {{{
  let s:list = s:list->map(function("s:format_item(v:val)"))
endfunction  " }}}

function s:format_item(_, item) abort  " {{{
  let [description, command] = a:item

  if empty(description)
    return ""
  else
    return description..s:word_padding(description).."  --  `"..command.."`"
  endif
endfunction  " }}}

function s:word_padding(item) abort  " {{{
  return repeat(" ", s:max_label_length - strlen(a:item))
endfunction  " }}}
