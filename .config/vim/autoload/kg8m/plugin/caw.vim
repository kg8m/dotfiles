vim9script

import autoload "kg8m/plugin.vim"

const SID = expand("<SID>")

export def OnSource(): void
  g:caw_no_default_keymappings = true
  g:caw_hatpos_skip_blank_line = true
enddef

export def Run(): string
  SetupFiletype()

  const base         = "\<Plug>(caw:hatpos:toggle)"
  const teardown     = $":call {SID}Teardown()\<CR>"
  const clear_status = ":echo ''\<CR>"
  return base .. teardown .. clear_status
enddef

def SetupFiletype(): void
  if &filetype ==# "eruby"
    SetupEruby()
  elseif &filetype ==# "jsonc"
    SetupJsonc()
  elseif &filetype ==# "Gemfile"
    SetupGemfile()
  elseif &filetype ==# "vim"
    SetupVim()
  endif
enddef

def SetupEruby(): void
  caw#load_ftplugin("eruby")

  const startline = line(mode() ==? "v" ? "'<" : ".")
  const endline   = line(mode() ==? "v" ? "'>" : ".")

  var eruby_tag_exists         = false
  var are_all_default_comments = true

  for lnum in range(startline, endline)
    const line = getline(lnum)

    if line =~# '<%\|%>'
      eruby_tag_exists = true
    endif

    if line !~# '^\s*<%#.*%>\s*$'
      are_all_default_comments = false
    endif

    if eruby_tag_exists && !are_all_default_comments
      break
    endif
  endfor

  if eruby_tag_exists && !are_all_default_comments
    # `<%# ... %>` doesn’t work if other `<% ... %>` markers exist. For example, commented out `<%# <%= foo %> %>` for
    # `<%= foo %>` is invalid.
    b:caw_wrap_oneline_comment = ["<% if false %>", "<% end %>"]
    b:caw_wrap_sp_left  = ""
    b:caw_wrap_sp_right = ""
  else
    b:caw_wrap_sp_left  = " "
    b:caw_wrap_sp_right = " "
  endif

  # Prevent context_filetype.vim from detecting filetype as Ruby.
  if eruby_tag_exists
    b:caw_context_filetype_original_filetypes = get(b:, "context_filetype_filetypes", v:null)
    b:context_filetype_filetypes = {}
  endif
enddef

def SetupJsonc(): void
  b:caw_oneline_comment = "//"
enddef

def SetupGemfile(): void
  caw#load_ftplugin("ruby")
enddef

# Overwrite caw.vim’s default: https://github.com/tyru/caw.vim/blob/41be34ca231c97d6be6c05e7ecb5b020f79cd37f/after/ftplugin/vim/caw.vim#L5-L9
def SetupVim(): void
  b:caw_hatpos_sp  = " "
  b:caw_zeropos_sp = " "
enddef

def Teardown(): void
  if has_key(b:, "caw_context_filetype_original_filetypes")
    unlet b:context_filetype_filetypes

    if b:caw_context_filetype_original_filetypes
      b:context_filetype_filetypes = b:caw_context_filetype_original_filetypes
    endif

    unlet b:caw_context_filetype_original_filetypes
  endif
enddef

plugin.EnsureSourced("caw.vim")
