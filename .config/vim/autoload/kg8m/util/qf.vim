vim9script

g:kg8m#util#qf#dirpath   = $"{$XDG_DATA_HOME}/vim/qf"
g:kg8m#util#qf#extension = "json"

mkdir(g:kg8m#util#qf#dirpath, "p")

export def List(): list<string>
  const command = [
    "fd",
    $FD_DEFAULT_OPTIONS,
    "--strip-cwd-prefix",
    "--type", "f",
    "--base-directory", shellescape(g:kg8m#util#qf#dirpath),
    "--extension", kg8m#util#qf#extension,
    "--color", "always",
    "| sort_without_escape_sequences",
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
      ->filter((_, name) => name =~# $"^{arglead}")
  endif
enddef

export def Save(name: string = ""): void
  const raw_list = getqflist()

  if empty(raw_list)
    kg8m#util#logger#Error("Quickfix list is empty. Do nothing.")
    return
  endif

  const filepath = NameToFilepath(
    empty(name) ? strftime("%Y%m%dT%H%M%S") : name
  )

  if filereadable(filepath)
    const prompt = $"`{filepath}` exists. Overwrite it?"

    if kg8m#util#input#Confirm(prompt)
      redraw
    else
      redraw
      echo "Canceled."
      return
    endif
  endif

  const encoded_list = EncodeList(raw_list)
  writefile(encoded_list, filepath)

  kg8m#util#logger#Info($"Quickfix list is saved to `{filepath}`.")
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
      execute "edit" fnameescape(filepath)
    })
  endif
enddef

export def Delete(name: string = ""): void
  if empty(name)
    kg8m#plugin#fzf#qf#Delete()
  else
    Process(name, (filepath) => {
      const prompt = $"Sure to delete `{filepath}`?"

      if kg8m#util#input#Confirm(prompt)
        delete(filepath)
        kg8m#util#logger#Info($"`{filepath}` has been deleted.")
      else
        kg8m#util#logger#Info($"`{filepath}` remains.")
      endif
    })
  endif
enddef

def Process(name: string, Callback: func(string)): void
  const filepath = NameToFilepath(name)

  if filereadable(filepath)
    Callback(filepath)
  else
    kg8m#util#logger#Error($"`{filepath}` doesn't exist.")
  endif
enddef

def NameToFilepath(name: string): string
  return $"{g:kg8m#util#qf#dirpath}/{name}.{kg8m#util#qf#extension}"
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
