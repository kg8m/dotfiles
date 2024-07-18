vim9script

export def Base(): void
  augroup vimrc-configure-comments
    autocmd!
    autocmd FileType * Set()
  augroup END
enddef

# format-comments flags:
#   n: Nested comment. Nesting with mixed parts is allowed. If 'comments' is "n:),n:>" a line starting with "> ) >" is a
#      comment.
#   b: Blank (<Space>, <Tab> or <EOL>) required after {string}.
#   f: Only the first line has the comment string. Do not repeat comment on the next line, but preserve indentation
#      (e.g., a bullet-list).
#   s: Start of three-piece comment
#   m: Middle of a three-piece comment
#   e: End of a three-piece comment
def Set(): void
  if &filetype =~# '\v^(gitcommit|markdown)$'
    # Lists
    for marker in ["*", "-"]
      # Insert `* [ ]` after `* [ ] foo` or `* [x] foo`.
      &l:comments ..= $",bs:{marker} [x],bm:{marker} [ ],b:{marker}"
    endfor

    # Insert `1. ` after `1. foo`.
    setlocal comments+=b:1.

    # Insert `3. ` after `2. foo`, `4. ` after `3. foo`, ..., and `9. ` after `8. foo`.
    for number in range(2, 8)->reverse()
      &l:comments ..= $",bs:{number}.,be:{number + 1}."
    endfor

    # Blockquote
    setlocal comments+=nb:\>

    # Clear defaults.
    setlocal com-=fb:* com-=fb:- com-=fb:+ com-=n:\>
  elseif &filetype ==# "slim"
    # Clear `comments` set by vim-ruby.
    setlocal comments-=b:#

    setlocal comments+=b:/
  endif
enddef
