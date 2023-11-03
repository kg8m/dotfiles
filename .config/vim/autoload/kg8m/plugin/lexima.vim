vim9script

import autoload "kg8m/configure/filetypes/javascript.vim" as jsConfig
import autoload "kg8m/events.vim"
import autoload "kg8m/util/matchpairs.vim"

var queue_on_post_source: list<func>

export def OnSource(): void
  g:lexima_enable_endwise_rules = false
enddef

export def OnPostSource(): void
  queue_on_post_source = [
    # Delay for performance.
    () => AddCommonRules(),
    () => AddRulesForEruby(),
    () => AddRulesForHtml(),
    () => AddRulesForJs(),
    () => AddRulesForTs(),
    () => AddRulesForMarkdown(),
    () => AddRulesForShell(),
    () => AddRulesForVim(),

    # Overwrite lexima.vim's default mapping.
    () => events.NotifyInsertModePluginLoaded(),
  ]

  DequeueOnPostSource()
enddef

def AddCommonRules(): void
  for pair in matchpairs.JapanesePairs()
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
    "markdown",
    "vue",
  ] + jsConfig.JS_FILETYPES + jsConfig.TS_FILETYPES

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
  const filetypes = jsConfig.JS_FILETYPES + jsConfig.TS_FILETYPES

  # `<CR>` when
  #
  #   `|`
  #
  # then
  #
  #   `
  #   |
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

def AddRulesForShell(): void
  const filetypes = ["sh", "zsh"]

  # `<CR>` when
  #
  #   (|)
  #
  # then
  #
  #   (
  #     |
  #   )
  lexima#add_rule({ char: "<CR>", at: '(\%#)', input: '<CR><Tab><C-o><S-o><Tab>', filetype: filetypes })

  # `<CR>` when
  #
  #   $(|)
  #
  # then
  #
  #   $(
  #     |
  #   )
  lexima#add_rule({ char: "<CR>", at: '\$(\%#)', input: '<CR><C-o><S-o><Tab>', filetype: filetypes })
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

  for pair in [['(', ')'], ['[', ']'], ['{', '}']]
    # `<CR>` when
    #
    #   (|)
    #   [|]
    #   {|}
    #
    # or
    #
    #   vim9script
    #
    #   (|)
    #   [|]
    #   {|}
    #
    # then
    #
    #   (
    #   \   |
    #   \ )
    #
    #   [
    #   \   |
    #   \ ]
    #
    #   {
    #   \   |
    #   \ }
    #
    # or
    #
    #   vim9script
    #
    #   (
    #     |
    #   )
    #
    #   [
    #     |
    #   ]
    #
    #   {
    #     |
    #   }
    lexima#add_rule({ char: "<CR>", at: $'\V{pair[0]}\%#{pair[1]}', input: '<C-r>=kg8m#plugin#lexima#ExprOnCrInEmptyParenthesesForVimScript()<CR>', filetype: filetypes })
  endfor
enddef

export def ExprOnCrInEmptyParenthesesForVimScript(): string
  if search('^vim9s\%[cript]\>', "bnW")
    return "\<CR>\<C-o>\<S-o>"
  else
    const pseudo_indentation = matchstr(getline("."), '\v^\s*\\ \zs +\ze')
    return $"\<CR>\\ {pseudo_indentation}\<C-o>\<S-o>\\ {pseudo_indentation}  "
  endif
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
