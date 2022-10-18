vim9script

var queue_on_post_source: list<func>

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

def AddCommonRules(): void
  for pair in kg8m#util#matchpairs#JapanesePairs()
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
    lexima#add_rule({ char: pair[1], at: $'\%#{pair[1]}', leave: 1 })

    # `<BS>` when
    #
    #   「|」
    #
    # then
    #
    #   |
    #
    lexima#add_rule({ char: "<BS>", at: join(pair, '\%#'), delete: 1 })
  endfor

  # `"` when
  #
  #   "foo|
  #
  # or
  #
  #   'foo|
  #
  # then
  #
  #   "foo"|
  #
  # or
  #
  #   'foo'|
  lexima#add_rule({ char: '"', except: '\%#"', syntax: "String" })
  lexima#add_rule({ char: "'", except: "\\%#'", syntax: "String" })
enddef

def AddRulesForEruby(): void
  # `%` when
  #
  #   <|
  #
  # then
  #
  #   <%| %>
  lexima#add_rule({ char: "%", at: '<\%#', input_after: "<Space>%>", filetype: "eruby" })
enddef

def AddRulesForHtml(): void
  # JavaScript and TypeScript for html`...`
  const filetypes = [
    "eruby",
    "html",
    "javascript",
    "javascriptreact",
    "markdown",
    "typescript",
    "typescriptreact",
    "vue",
  ]

  # `<CR>` when
  #
  #   <foo>|</foo>
  #
  # then
  #
  #   <foo>
  #     |
  #   </foo>
  lexima#add_rule({ char: "<CR>", at: '>\%#</', input_after: "<CR>", filetype: filetypes })

  # `-` when
  #
  #   <!-|
  #
  # then
  #
  #   <!-- | -->
  lexima#add_rule({ char: "-", at: '<!-\%#', input: "-<Space>", input_after: "<Space>-->", filetype: filetypes })
enddef

def AddRulesForJs(): void
  const filetypes = ["javascript", "javascriptreact", "typescript", "typescriptreact"]

  # `<CR>` when
  #
  #   `|`
  #
  # then
  #
  #   `
  #     |
  #   `
  lexima#add_rule({ char: "<CR>", at: '`\%#`', input_after: "<CR>", filetype: filetypes })
enddef

def AddRulesForTs(): void
  const filetypes = ["typescript"]

  # `<` when
  #
  #   Foo|
  #
  # then
  #
  #   Foo<|>
  lexima#add_rule({ char: "<", at: '\w\%#', input_after: ">", filetype: filetypes })

  # `<` when
  #
  #   Foo|<
  #
  # then
  #
  #   Foo<|
  #
  # NOTE: Use `input: "<Right>"` because `leave: 1` doesn't work.
  lexima#add_rule({ char: "<", at: '\w\%#<', input: "<C-g>U<Right>", filetype: filetypes })

  # `<` when
  #
  #   |(
  #
  # then
  #
  #   <|>(
  lexima#add_rule({ char: "<", at: '\%#(', input_after: ">", filetype: filetypes })

  # `>` when
  #
  #   <foo|>
  #
  # then
  #
  #   <foo>|
  #
  # NOTE: Use `input: "<Right>"` because `leave: 1` doesn't work.
  lexima#add_rule({ char: ">", at: '\%#>', input: "<C-g>U<Right>", filetype: filetypes })

  # `<BS>` when
  #
  #   <|>
  #
  # then
  #
  #   |
  #
  lexima#add_rule({ char: "<BS>", at: '<\%#>', delete: 1, filetype: filetypes })
enddef

def AddRulesForMarkdown(): void
  const filetypes = ["gitcommit", "markdown"]

  # `<Space>` when
  #
  #   - [|]
  #   * [|]
  #   1. [|]
  #
  # then
  #
  #   - [ ] |
  #   * [ ] |
  #   1. [ ] |
  lexima#add_rule({ char: "<Space>", at: '\v^\s*%([-*]|\d+\.)\s+\[%#\]', input: "<Space><C-g>U<Right><Space>", filetype: filetypes })

  for pattern in ['\*', '-', '\d+\.']
    # `<CR>` when
    #
    #   * |
    #   - |
    #   1. |
    #   2. |
    #   * [ ] |
    #   - [ ] |
    #
    # then
    #
    #   |
    lexima#add_rule({ char: "<CR>", at: $'\v^\s*{pattern}\s(\[[x ]\]\s)?%#$', input: $"<C-o>0d$", filetype: filetypes })
  endfor

  # `<CR>` when
  #
  #   ```|```
  #
  # then
  #
  #   ```
  #   |
  #   ```
  lexima#add_rule({ char: "<CR>", at: '```\%#```', input_after: "<CR>", filetype: filetypes })

  # `<CR>` when
  #
  #   ```foo|```
  #
  # then
  #
  #   ```foo
  #   |
  #   ```
  lexima#add_rule({ char: "<CR>", at: '```[a-z]\+\%#```', input_after: "<CR>", filetype: filetypes })

  # ``` when
  #
  #   `foo|
  #
  # then
  #
  #   `foo`|
  lexima#add_rule({ char: "`", except: '\%#`\|``\%#', syntax: ["mkdCode", "mkdInlineCodeDelimiter"] })
enddef

def AddRulesForVim(): void
  const filetypes = ["vim"]

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
  # NOTE: Always write comments at the beginning of line (indentation is allowed).
  lexima#add_rule({ char: '"', at: '\S.*\%#\%([^"]\|$\)', except: '\%#"', input_after: '"', filetype: filetypes })
  lexima#add_rule({ char: '"', at: '\%#"', leave: 1, filetype: filetypes })

  # `<` when
  #
  #   foo|
  #
  # then
  #
  #   foo<|>
  lexima#add_rule({ char: "<", at: '\w\%#', input_after: ">", filetype: filetypes })

  # `<` when
  #
  #   foo|<
  #
  # then
  #
  #   foo<|
  #
  # NOTE: Use `input: "<Right>"` because `leave: 1` doesn't work.
  lexima#add_rule({ char: "<", at: '\w\%#<', input: "<C-g>U<Right>", filetype: filetypes })

  # `>` when
  #
  #   <foo|>
  #
  # then
  #
  #   <foo>|
  #
  # NOTE: Use `input: "<Right>"` because `leave: 1` doesn't work.
  lexima#add_rule({ char: ">", at: '\%#>', input: "<C-g>U<Right>", filetype: filetypes })

  # `<BS>` when
  #
  #   <|>
  #
  # then
  #
  #   |
  #
  lexima#add_rule({ char: "<BS>", at: '<\%#>', delete: 1, filetype: filetypes })
enddef

def DequeueOnPostSource(): void
  if !empty(queue_on_post_source)
    const Callback = remove(queue_on_post_source, 0)
    timer_start(50, (_) => CallbackProxyOnPostSource(Callback))
  endif
enddef

def CallbackProxyOnPostSource(Callback: func): void
  Callback()
  DequeueOnPostSource()
enddef

def OnSource(): void
  g:lexima_enable_endwise_rules = false
enddef

def OnPostSource(): void
  queue_on_post_source = [
    # Delay for performance.
    () => AddCommonRules(),
    () => AddRulesForEruby(),
    () => AddRulesForHtml(),
    () => AddRulesForJs(),
    () => AddRulesForTs(),
    () => AddRulesForMarkdown(),
    () => AddRulesForVim(),

    # Overwrite lexima.vim's default mapping.
    () => kg8m#events#NotifyInsertModePluginLoaded(),
  ]

  DequeueOnPostSource()
enddef
