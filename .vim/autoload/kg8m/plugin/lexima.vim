function kg8m#plugin#lexima#configure() abort  " {{{
  let g:lexima_ctrlh_as_backspace = v:true

  call kg8m#plugin#configure(#{
  \   lazy: v:true,
  \   on_i: v:true,
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:add_common_rules() abort  " {{{
  for pair in kg8m#util#japanese_matchpairs()
    " `「` when
    "
    "   |
    "
    " then
    "
    "   「|」
    call lexima#add_rule(#{ char: pair[0], input_after: pair[1] })

    " `」` when
    "
    "   |」
    "
    " then
    "
    "   」|
    call lexima#add_rule(#{ char: pair[1], at: '\%#'..pair[1], leave: 1 })

    " `<BS>` when
    "
    "   「|」
    "
    " then
    "
    "   |
    "
    " Use `"<BS><Del>"` instead of `delete: 1` option because the option doesn't work
    call lexima#add_rule(#{ char: "<BS>", at: join(pair, '\%#'), input: "<BS><Del>" })
  endfor
endfunction  " }}}

function s:add_rules_for_eruby() abort  " {{{
  " `<Space>` when
  "
  "   <%|
  "
  " then
  "
  "   <% | %>
  call lexima#add_rule(#{ char: "<Space>", at: '<%\%#', input_after: "<Space>%>", filetype: "eruby" })

  " `<Space>` when
  "
  "   <%|... %>
  "
  " then
  "
  "   <% |... %>
  call lexima#add_rule(#{ char: "<Space>", at: '<%\%#.*%>', leave: 1, filetype: "eruby" })

  " `<Space>` when
  "
  "   <%=|
  "
  " or
  "
  "   <%=something|
  "
  " then
  "
  "   <%= | %>
  "
  " or
  "
  "   <%=something | %>
  call lexima#add_rule(#{ char: "<Space>", at: '<%=\S*\%#', input_after: "<Space>%>", filetype: "eruby" })

  " `<Space>` when
  "
  "   <%=|... %>
  "
  " or
  "
  "   <%=something|... %>
  "
  " then
  "
  "   <%= |... %>
  "
  " or
  "
  "   <%=something ... %>
  call lexima#add_rule(#{ char: "<Space>", at: '<%=\S*\%#.*%>', leave: 1, filetype: "eruby" })
endfunction  " }}}

function s:add_rules_for_markdown() abort  " {{{
  " `<Space>` when
  "
  "   [|]
  "
  " then
  "
  "   [ ] |
  call lexima#add_rule(#{ char: "<Space>", at: '\[\%#]', input: "<Space><Right><Space>", filetype: ["gitcommit", "markdown"] })

  " `<Cr>` when
  "
  "   ```|```
  "
  " then
  "
  "   ```
  "   |
  "   ```
  call lexima#add_rule(#{ char: "<Cr>", at: '```\%#```', input_after: "<Cr>", filetype: ["gitcommit", "markdown"] })

  " `<Cr>` when
  "
  "   ```foo|```
  "
  " then
  "
  "   ```foo
  "   |
  "   ```
  call lexima#add_rule(#{ char: "<Cr>", at: '```[a-z]\+\%#```', input_after: "<Cr>", filetype: ["gitcommit", "markdown"] })
endfunction  " }}}

function s:add_rules_for_vim() abort  " {{{
  " `"` when
  "
  "   ...|
  "
  " or
  "
  "   ...|"
  "
  " then
  "
  "   ..."|"
  "
  " or
  "
  "   ..."|
  "
  " NOTE: Always write comments at the beginning of line (indentation is allowed)
  " Use `"<Right>"` instead of `leave: 1` option because the option doesn't work
  call lexima#add_rule(#{ char: '"', at: '\S.*\%#\%([^"]\|$\)', input_after: '"', filetype: "vim" })
  call lexima#add_rule(#{ char: '"', at: '\%#"', input: "<Right>", filetype: "vim" })
endfunction  " }}}

function s:on_post_source() abort  " {{{
  call s:add_common_rules()
  call s:add_rules_for_eruby()
  call s:add_rules_for_markdown()
  call s:add_rules_for_vim()

  call kg8m#plugin#mappings#define_cr_for_insert_mode()
  call kg8m#plugin#mappings#define_bs_for_insert_mode()
endfunction  " }}}
