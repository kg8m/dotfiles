function kg8m#plugin#asyncomplete#buffer#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call timer_start(0, { -> s:setup() })
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_source: "asyncomplete.vim",
  \ })
endfunction  " }}}

" https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L51-L57
function kg8m#plugin#asyncomplete#buffer#on_event(_timer_id) abort  " {{{
  if !has_key(s:, "refresh_keywords")
    call s:setup_refresh_keywords()
  endif

  call s:refresh_keywords()
  call s:stop_refresh_timer()
endfunction  " }}}

function s:setup() abort  " {{{
  " Call asyncomplete-buffer.vim's function to refresh keywords (`s:refresh_keywords`) on some events not only
  " `BufWinEnter` in order to include keywords added after `BufWinEnter` in completion candidates
  " https://github.com/prabirshrestha/asyncomplete-buffer.vim/blob/b88179d74be97de5b2515693bcac5d31c4c207e9/autoload/asyncomplete/sources/buffer.vim#L29
  let events = [
  \   "BufWinEnter",
  \   "TextChanged",
  \   "TextChangedI",
  \   "TextChangedP",
  \ ]

  call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options(#{
  \   name: "buffer",
  \   allowlist: ["*"],
  \   completor: function("asyncomplete#sources#buffer#completor"),
  \   events: events,
  \   on_event: function("s:on_event_async"),
  \   priority: 2,
  \ }))

  call s:activate()
endfunction  " }}}

function s:on_event_async(...) abort  " {{{
  call s:stop_refresh_timer()
  call s:start_refresh_timer()
endfunction  " }}}

function s:start_refresh_timer() abort  " {{{
  let s:refresh_timer = timer_start(200, function("kg8m#plugin#asyncomplete#buffer#on_event"))
endfunction  " }}}

function s:stop_refresh_timer() abort  " {{{
  if has_key(s:, "refresh_timer")
    call timer_stop(s:refresh_timer)
    unlet s:refresh_timer
  endif
endfunction  " }}}

function s:setup_refresh_keywords() abort  " {{{
  for scriptname in split(execute("scriptnames"), '\n')
    if scriptname =~# 'asyncomplete-buffer\.vim/autoload/asyncomplete/sources/buffer\.vim'
      let s:asyncomplete_buffer_sid = matchstr(scriptname, '\v^ *(\d+)')
      break
    endif
  endfor

  if has_key(s:, "asyncomplete_buffer_sid")
    let s:refresh_keywords = function("<SNR>"..s:asyncomplete_buffer_sid.."_refresh_keywords")
  else
    let s:refresh_keywords = function("s:cannot_refresh_keywords")
  endif
endfunction  " }}}

function s:cannot_refresh_keywords() abort
  call kg8m#util#echo_error_msg("Cannot refresh keywords because asyncomplete-buffer.vim's SID can't be detected.")
endfunction

function s:activate() abort  " {{{
  " Trigger one of the events given to `asyncomplete#sources#buffer#get_source_options`.
  " Don't use `TextChangedI` or `TextChangedP` because they cause asyncomplete.vim's error about previous_position.
  doautocmd <nomodeline> TextChanged
endfunction  " }}}
