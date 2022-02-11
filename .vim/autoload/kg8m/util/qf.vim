vim9script

g:kg8m#util#qf#dirpath   = $XDG_DATA_HOME .. "/vim/qf"
g:kg8m#util#qf#extension = "json"

mkdir(g:kg8m#util#qf#dirpath, "p")

export def List(): list<string>
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

export def Complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  const all = kg8m#util#qf#List()

  if empty(arglead)
    return all
  else
    return all
      ->copy()
      ->filter((_, name) => name =~# "^" .. arglead)
  endif
enddef

export def Save(name: string = ""): void
  const raw_list = getqflist()

  if empty(raw_list)
    kg8m#util#logger#Error("Quickfix list is empty. Do nothing.")
    return
  endif

  const filepath = NameToFilepath(
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

  const encoded_list = EncodeList(raw_list)
  writefile(encoded_list, filepath)

  printf("Quickfix list is saved to %s.", shellescape(filepath))->kg8m#util#logger#Info()
enddef

export def Load(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#Load()
  else
    Process(name, (filepath) => {
      const encoded_list = readfile(filepath)
      const decoded_list = DecodeList(encoded_list)

      setqflist(decoded_list)
      copen
    })
  endif
enddef

export def Edit(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#Edit()
  else
    Process(name, (filepath) => {
      execute "edit " .. fnameescape(filepath)
    })
  endif
enddef

export def Delete(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#Delete()
  else
    Process(name, (filepath) => {
      const escaped_filepath = shellescape(filepath)
      const prompt = printf("Sure to delete %s? (y/n): ", escaped_filepath)

      if input(prompt) =~? '^y'
        delete(filepath)
        printf("%s has been deleted.", escaped_filepath)->kg8m#util#logger#Info()
      else
        printf("%s remains.", escaped_filepath)->kg8m#util#logger#Info()
      endif
    })
  endif
enddef

def Process(name: string, Callback: func(string)): void
  const filepath = NameToFilepath(name)

  if filereadable(filepath)
    Callback(filepath)
  else
    printf("%s doesn't exist.", shellescape(filepath))->kg8m#util#logger#Error()
  endif
enddef

def NameToFilepath(name: string): string
  return printf("%s/%s.%s", g:kg8m#util#qf#dirpath, name, kg8m#util#qf#extension)
enddef

def EncodeList(raw_list: list<dict<any>>): list<string>
  return mapnew(raw_list, (_, original_item) => {
    final item = copy(original_item)

    item.filename = bufname(item.bufnr)
    remove(item, "bufnr")

    return json_encode(item)
  })
enddef

def DecodeList(encoded_list: list<string>): list<dict<any>>
  return mapnew(encoded_list, (_, item) => json_decode(item))
enddef
