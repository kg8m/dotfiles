vim9script

# Get syntax name by `synIDattr(synID(line("."), col("."), 1), "name")`.

var s:queue_on_post_source: list<func>

def kg8m#plugin#lexima#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_i:     true,
    on_start: true,
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:add_common_rules(): void
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
    # Use `input: "<BS><Del>"` instead of `delete: 1` because it sometimes doesn't work depending on input stack.
    lexima#add_rule({ char: "<BS>", at: join(pair, '\%#'), input: "<BS><Del>" })
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

  # Overwrite default rules and use `input: "<BS><Del>"` instead of `delete: 1` because it sometimes doesn't work
  # depending on input stack.
  lexima#add_rule({ char: "<BS>", at: '"\%#"', input: "<BS><Del>" })
  lexima#add_rule({ char: "<BS>", at: "'\\%#'", input: "<BS><Del>" })
enddef

def s:add_rules_for_eruby(): void
  # `%` when
  #
  #   <|
  #
  # then
  #
  #   <%| %>
  lexima#add_rule({ char: "%", at: '<\%#', input_after: "<Space>%>", filetype: "eruby" })
enddef

def s:add_rules_for_html(): void
  # JavaScript and TypeScript for html`...`
  const filetypes = ["eruby", "html", "javascript", "markdown", "typescript", "vue"]

  # https://developer.mozilla.org/en-US/docs/Web/HTML/Element
  const tagnames = [
    # Main root
    "html",

    # Document metadata
    "base", "head", "link", "meta", "style", "title",

    # Sectioning root
    "body",

    # Content sectioning
    "address", "article", "aside", "footer", "header", "h1", "h2", "h3", "h4", "h5", "h6", "hgroup", "main", "nav",
    "section",

    # Text content
    "blockquote", "dd", "div", "dl", "dt", "figcaption", "figure", "hr", "li", "main", "ol", "p", "pre", "ul",

    # Inline text semantics
    "a", "abbr", "b", "bdi", "bdo", "br", "cite", "code", "data", "dfn", "em", "i", "kbd", "mark", "q", "rb", "rp",
    "rt", "rtc", "ruby", "s", "samp", "small", "span", "strong", "sub", "sup", "time", "u", "var", "wbr",

    # Image and multimedia
    "area", "audio", "img", "map", "track", "video",

    # Embedded content
    "embed", "iframe", "object", "param", "picture", "source",

    # SVG and MathML
    "svg", "math",

    # Scripting
    "canvas", "noscript", "script",

    # Demarcating edits
    "del", "ins",

    # Table content
    "caption", "col", "colgroup", "table", "tbody", "td", "tfoot", "th", "thead", "tr",

    # Forms
    "button", "datalist", "fieldset", "form", "input", "label", "legend", "meter", "optgroup", "option", "output",
    "progress", "select", "textarea",

    # Interactive elements
    "details", "dialog", "menu", "summary",

    # Web Components
    "content", "element", "shadow", "slot", "template",
  ]

  for tagname in tagnames
    # `>` when
    #
    #   <foo|
    #
    # or
    #
    #   <foo /|
    #
    # then
    #
    #   <foo>|</foo>
    #
    # or
    #
    #   <foo />|
    lexima#add_rule({ char: ">", at: '<' .. tagname .. '\>[^>]*\%#', except: '/\%#', input_after: "</" .. tagname .. ">", filetype: filetypes })
  endfor

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

  # `!` when
  #
  #   <|
  #
  # then
  #
  #   <!-- | -->
  lexima#add_rule({ char: "!", at: '<\%#', input: "!--<Space>", input_after: "<Space>-->", filetype: filetypes })
enddef

def s:add_rules_for_js(): void
  const filetypes = ["javascript", "typescript"]

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

def s:add_rules_for_ts(): void
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
  lexima#add_rule({ char: "<", at: '\w\%#<', input: "<Right>", filetype: filetypes })

  # `>` when
  #
  #   <foo|>
  #
  # then
  #
  #   <foo>|
  #
  # NOTE: Use `input: "<Right>"` because `leave: 1` doesn't work.
  lexima#add_rule({ char: ">", at: '\%#>', input: "<Right>", filetype: filetypes })
enddef

def s:add_rules_for_markdown(): void
  const filetypes = ["gitcommit", "markdown"]

  # `<Space>` when
  #
  #   - [|]
  #   * [|]
  #
  # then
  #
  #   - [ ] |
  #   * [ ] |
  lexima#add_rule({ char: "<Space>", at: '^\s*[-*]\+\s\+\[\%#\]', input: "<Space><Right><Space>", filetype: filetypes })

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

def s:add_rules_for_vim(): void
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
  lexima#add_rule({ char: '"', at: '\S.*\%#\%([^"]\|$\)', except: '\%#"', input_after: '"', filetype: "vim" })
  lexima#add_rule({ char: '"', at: '\%#"', leave: 1, filetype: "vim" })
enddef

def s:dequeue_on_post_source(): void
  if !empty(s:queue_on_post_source)
    const Callback = remove(s:queue_on_post_source, 0)
    timer_start(50, (_) => s:callback_proxy_on_post_source(Callback))
  endif
enddef

def s:callback_proxy_on_post_source(Callback: func): void
  Callback()
  s:dequeue_on_post_source()
enddef

def s:on_source(): void
  g:lexima_enable_endwise_rules = false
  g:lexima_ctrlh_as_backspace   = true
enddef

def s:on_post_source(): void
  s:queue_on_post_source = [
    # Delay for performance.
    () => s:add_common_rules(),
    () => s:add_rules_for_eruby(),
    () => s:add_rules_for_html(),
    () => s:add_rules_for_js(),
    () => s:add_rules_for_ts(),
    () => s:add_rules_for_markdown(),
    () => s:add_rules_for_vim(),

    # Overwrite lexima.vim's default mapping.
    () => kg8m#events#notify_insert_mode_plugin_loaded(),
  ]

  s:dequeue_on_post_source()
enddef
