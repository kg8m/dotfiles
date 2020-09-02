let s:registered = []
let s:configs    = []
let s:filetypes  = []

function! kg8m#plugin#lsp#register(config) abort  " {{{
  if has_key(a:config, "executable_name")
    let executable_name = a:config.executable_name
    call remove(a:config, "executable_name")
  else
    let executable_name = a:config.name
  endif

  if executable(executable_name)
    if !has_key(a:config, "root_uri")
      let a:config.root_uri = { server_info -> lsp#utils#path_to_uri(getcwd()) }
    endif

    let s:configs   += [a:config]
    let s:filetypes += a:config.allowlist

    call add(s:registered, #{ name: a:config.name, available: v:true })
  else
    call add(s:registered, #{ name: a:config.name, available: v:false })
  endif
endfunction  " }}}

function! kg8m#plugin#lsp#enable() abort  " {{{
  for config in s:configs
    for key in ["config", "initialization_options", "workspace_config"]
      if has_key(config, key) && type(config[key]) ==# v:t_func
        let config[key] = config[key]()
      endif
    endfor

    call lsp#register_server(config)
  endfor
endfunction  " }}}

function! kg8m#plugin#lsp#get_registered() abort  " {{{
  return s:registered
endfunction  " }}}

function! kg8m#plugin#lsp#get_filetypes() abort  " {{{
  return s:filetypes
endfunction  " }}}
