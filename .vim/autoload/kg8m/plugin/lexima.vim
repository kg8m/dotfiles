vim9script

def kg8m#plugin#lexima#configure(): void  # {{{
  g:lexima_ctrlh_as_backspace = true

  kg8m#plugin#configure({
    lazy: true,
    on_i: true,
    hook_post_source: () => s:on_post_source(),
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
  lexima#add_rule({ char: "<Space>", at: '<%\%#', except: '<%\%#.*%>', input_after: "<Space>%>", filetype: "eruby" })

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
  lexima#add_rule({ char: "<Space>", at: '<%=\S*\%#', except: '<%=\S*\%#.*%>', input_after: "<Space>%>", filetype: "eruby" })
enddef  # }}}

def s:add_rules_for_html(): void  # {{{
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
    # then
    #
    #   <foo>|</foo>
    lexima#add_rule({ char: ">", at: '<' .. tagname .. '\>[^>]*\%#', input_after: "</" .. tagname .. ">", filetype: ["eruby", "html"] })
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
  lexima#add_rule({ char: "<CR>", at: '>\%#</', input_after: "<CR>", filetype: ["eruby", "html"] })
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
  lexima#add_rule({ char: '"', at: '\S.*\%#\%([^"]\|$\)', except: '\%#"', input_after: '"', filetype: "vim" })
  lexima#add_rule({ char: '"', at: '\%#"', leave: 1, filetype: "vim" })
enddef  # }}}

def s:on_post_source(): void  # {{{
  # Delay for performance
  timer_start(50, () => s:add_common_rules())
  timer_start(50, () => s:add_rules_for_eruby())
  timer_start(50, () => s:add_rules_for_html())
  timer_start(50, () => s:add_rules_for_markdown())
  timer_start(50, () => s:add_rules_for_vim())

  # Delay to overwrite lexima.vim's default mapping
  timer_start(100, () => kg8m#plugin#mappings#define_cr_for_insert_mode())
  timer_start(100, () => kg8m#plugin#mappings#define_bs_for_insert_mode())
enddef  # }}}
