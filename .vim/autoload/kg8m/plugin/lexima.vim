vim9script

def kg8m#plugin#lexima#configure(): void  # {{{
  g:lexima_ctrlh_as_backspace = true

  kg8m#plugin#configure({
    lazy: true,
    on_i: true,
    hook_post_source: function("s:on_post_source"),
  })
enddef  # }}}

def s:add_common_rules(): void  # {{{
  for pair in kg8m#util#japanese_matchpairs()
    # `「` when
    #
    #   |
    #
    # then
    #
    #   「|」
    lexima#add_rule({ char: pair[0], input_after: pair[1] })

    # `」` when
    #
    #   |」
    #
    # then
    #
    #   」|
    lexima#add_rule({ char: pair[1], at: '\%#' .. pair[1], leave: 1 })

    # `<BS>` when
    #
    #   「|」
    #
    # then
    #
    #   |
    #
    # Use `"<BS><Del>"` instead of `delete: 1` option because the option doesn't work
    lexima#add_rule({ char: "<BS>", at: join(pair, '\%#'), input: "<BS><Del>" })
  endfor
enddef  # }}}

def s:add_rules_for_eruby(): void  # {{{
  # `<Space>` when
  #
  #   <%|
  #
  # then
  #
  #   <% | %>
  lexima#add_rule({ char: "<Space>", at: '<%\%#', input_after: "<Space>%>", filetype: "eruby" })

  # `<Space>` when
  #
  #   <%|... %>
  #
  # then
  #
  #   <% |... %>
  lexima#add_rule({ char: "<Space>", at: '<%\%#.*%>', leave: 1, filetype: "eruby" })

  # `<Space>` when
  #
  #   <%=|
  #
  # or
  #
  #   <%=something|
  #
  # then
  #
  #   <%= | %>
  #
  # or
  #
  #   <%=something | %>
  lexima#add_rule({ char: "<Space>", at: '<%=\S*\%#', input_after: "<Space>%>", filetype: "eruby" })

  # `<Space>` when
  #
  #   <%=|... %>
  #
  # or
  #
  #   <%=something|... %>
  #
  # then
  #
  #   <%= |... %>
  #
  # or
  #
  #   <%=something ...%>
  lexima#add_rule({ char: "<Space>", at: '<%=\S*\%#.*%>', leave: 1, filetype: "eruby" })
enddef  # }}}

def s:add_rules_for_markdown(): void  # {{{
  # `<Space>` when
  #
  #   [|]
  #
  # then
  #
  #   [ ] |
  lexima#add_rule({ char: "<Space>", at: '\[\%#]', input: "<Space><Right><Space>", filetype: ["gitcommit", "markdown"] })

  # `<CR>` when
  #
  #   ```|```
  #
  # then
  #
  #   ```
  #   |
  #   ```
  lexima#add_rule({ char: "<CR>", at: '```\%#```', input_after: "<CR>", filetype: ["gitcommit", "markdown"] })

  # `<CR>` when
  #
  #   ```foo|```
  #
  # then
  #
  #   ```foo
  #   |
  #   ```
  lexima#add_rule({ char: "<CR>", at: '```[a-z]\+\%#```', input_after: "<CR>", filetype: ["gitcommit", "markdown"] })
enddef  # }}}

def s:add_rules_for_vim(): void  # {{{
  # `"` when
  #
  #   ...|
  #
  # or
  #
  #   ...|"
  #
  # then
  #
  #   ..."|"
  #
  # or
  #
  #   ..."|
  #
  # NOTE: Always write comments at the beginning of line (indentation is allowed)
  # Use `"<Right>"` instead of `leave: 1` option because the option doesn't work
  lexima#add_rule({ char: '"', at: '\S.*\%#\%([^"]\|$\)', input_after: '"', filetype: "vim" })
  lexima#add_rule({ char: '"', at: '\%#"', input: "<Right>", filetype: "vim" })
enddef  # }}}

def s:on_post_source(): void  # {{{
  s:add_common_rules()
  s:add_rules_for_eruby()
  s:add_rules_for_markdown()
  s:add_rules_for_vim()

  kg8m#plugin#mappings#define_cr_for_insert_mode()
  kg8m#plugin#mappings#define_bs_for_insert_mode()
enddef  # }}}
