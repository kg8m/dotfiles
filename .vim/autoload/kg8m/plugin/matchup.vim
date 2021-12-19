vim9script

def kg8m#plugin#matchup#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_start: true,
    hook_source: () => s:on_source(),
  })
enddef

def s:on_source(): void
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
enddef
