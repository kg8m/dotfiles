function kg8m#configure#formatoptions#base() abort  " {{{
  augroup my_vimrc  " {{{
    " Lazily set formatoptions to overwrite others
    autocmd FileType * call s:set()
    autocmd FileType * call timer_start(300, { -> s:set() })
  augroup END  " }}}
endfunction  " }}}

function s:set() abort  " {{{
  " Formatoptions:
  "   t: Auto-wrap text using textwidth.
  "   c: Auto-wrap comments using textwidth, inserting the current comment leader automatically.
  "   r: Automatically insert the current comment leader after hitting <Enter> in Insert mode.
  "   o: Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
  "   q: Allow formatting of comments with "gq".
  "   a: Automatic formatting of paragraphs. Every time text is inserted or deleted the paragraph will be reformatted.
  "   2: When formatting text, use the indent of the second line of a paragraph for the rest of the paragraph, instead
  "      of the indent of the first line.
  "   b: Like 'v', but only auto-wrap if you enter a blank at or before the wrap margin.
  "   l: Long lines are not broken in insert mode: When a line was longer than textwidth when the insert command
  "      started, Vim does not.
  "   M: When joining lines, don't insert a space before or after a multi-byte character.  Overrules the 'B' flag.
  "   j: Where it makes sense, remove a comment leader when joining lines.
  "   ]: Respect textwidth rigorously. With this flag set, no line can be longer than textwidth, unless
  "      line-break-prohibition rules make this impossible. Mainly for CJK scripts and works only if 'encoding' is
  "      utf-8".
  setlocal fo+=roq2lMj
  setlocal fo-=t fo-=c fo-=a fo-=b  " `fo-=tcab` doesn't work

  if &encoding ==# "utf-8"
    setlocal fo+=]
  endif

  if &filetype =~# '\v^(gitcommit|markdown|moin|text)$'
    setlocal fo-=r fo-=o
  endif
endfunction  " }}}
