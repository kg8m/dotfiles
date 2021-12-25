vim9script

g:kg8m#util#qf#dirpath   = $XDG_DATA_HOME .. "/vim/qf"
g:kg8m#util#qf#extension = "json"

mkdir(g:kg8m#util#qf#dirpath, "p")

def kg8m#util#qf#list(): list<string>
  const command = [
    "fd",
    "--hidden",
    "--type", "f",
    "--base-directory", shellescape(g:kg8m#util#qf#dirpath),
    "--extension", kg8m#util#qf#extension,

    # Sort results.
    "--threads", "1",
  ]->join(" ")

  return system(command)
    ->split("\n")
    ->map((_, filepath) => fnamemodify(filepath, ":t:r"))
enddef

def kg8m#util#qf#complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  const all = kg8m#util#qf#list()

  if empty(arglead)
    return all
  else
    return all
      ->copy()
      ->filter((_, name) => name =~# "^" .. arglead)
  endif
enddef

def kg8m#util#qf#save(name: string = ""): void
  const raw_list = getqflist()

  if empty(raw_list)
    kg8m#util#logger#error("Quickfix list is empty. Do nothing.")
    return
  endif

  const filepath = s:name_to_filepath(
    empty(name) ? strftime("%Y-%m-%dT%H:%M:%S") : name
  )

  if filereadable(filepath)
    const prompt = printf("%s exists. Overwrite it? (y/n): ", shellescape(filepath))

    if input(prompt) =~? '^y'
      redraw
    else
      redraw
      echo "Canceled."
      return
    endif
  endif

  const encoded_list = s:encode_list(raw_list)
  writefile(encoded_list, filepath)

  printf("Quickfix list is saved to %s.", shellescape(filepath))->kg8m#util#logger#info()
enddef

def kg8m#util#qf#load(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#load()
  else
    s:process(name, (filepath) => {
      const encoded_list = readfile(filepath)
      const decoded_list = s:decode_list(encoded_list)

      setqflist(decoded_list)
      copen
    })
  endif
enddef

def kg8m#util#qf#edit(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#edit()
  else
    s:process(name, (filepath) => {
      execute "edit " .. fnameescape(filepath)
    })
  endif
enddef

def kg8m#util#qf#delete(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#delete()
  else
    s:process(name, (filepath) => {
      const escaped_filepath = shellescape(filepath)
      const prompt = printf("Sure to delete %s? (y/n): ", escaped_filepath)

      if input(prompt) =~? '^y'
        delete(filepath)
        printf("%s has been deleted.", escaped_filepath)->kg8m#util#logger#info()
      else
        printf("%s remains.", escaped_filepath)->kg8m#util#logger#info()
      endif
    })
  endif
enddef

def s:process(name: string, Callback: func): void
  const filepath = s:name_to_filepath(name)

  if filereadable(filepath)
    Callback(filepath)
  else
    printf("%s doesn't exist.", shellescape(filepath))->kg8m#util#logger#error()
  endif
enddef

def s:name_to_filepath(name: string): string
  return printf("%s/%s.%s", g:kg8m#util#qf#dirpath, name, kg8m#util#qf#extension)
enddef

def s:encode_list(raw_list: list<dict<any>>): list<string>
  return mapnew(raw_list, (_, original_item) => {
    final item = copy(original_item)

    item.filename = bufname(item.bufnr)
    remove(item, "bufnr")

    return json_encode(item)
  })
enddef

def s:decode_list(encoded_list: list<string>): list<dict<any>>
  return mapnew(encoded_list, (_, item) => json_decode(item))
enddef
