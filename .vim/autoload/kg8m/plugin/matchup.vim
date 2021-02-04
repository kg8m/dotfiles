vim9script

def kg8m#plugin#matchup#configure(): void
  g:matchup_no_version_check = true
  g:matchup_transmute_enabled = true
  g:matchup_matchparen_status_offscreen = false
  g:matchup_matchparen_deferred = true

  # Fade highlighting because it is noisy when editing HTML codes in JavaScript's template literal like html`...`
  g:matchup_matchparen_deferred_fade_time = 500

  g:matchup_matchpref = {
    html:  { tagnameonly: true },
    eruby: { tagnameonly: true },
  }

  augroup my_vimrc
    autocmd ColorScheme * s:overwrite_colors()
  augroup END
enddef

def s:overwrite_colors(): void
  # Original `highlight default link MatchParenCur MatchParen` is too confusing because current parenthesis looks as
  # same as matched one.
  highlight default link MatchParenCur Cursor
enddef
