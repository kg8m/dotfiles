function kg8m#plugin#matchup#configure() abort  " {{{
  let g:matchup_no_version_check = v:true
  let g:matchup_transmute_enabled = v:true
  let g:matchup_matchparen_status_offscreen = v:false
  let g:matchup_matchparen_deferred = v:true

  " Fade highlighting because it is noisy when editing HTML codes in JavaScript's template literal like html`...`
  let g:matchup_matchparen_deferred_fade_time = 500

  let g:matchup_matchpref = #{
  \   html:  #{ tagnameonly: v:true },
  \   eruby: #{ tagnameonly: v:true },
  \ }

  augroup my_vimrc  " {{{
    autocmd ColorScheme * call s:overwrite_colors()
  augroup END  " }}}
endfunction  " }}}

function s:overwrite_colors() abort  " {{{
  " Original `highlight default link MatchParenCur MatchParen` is too confusing because current parenthesis looks as
  " same as matched one.
  highlight default link MatchParenCur Cursor
endfunction  " }}}
