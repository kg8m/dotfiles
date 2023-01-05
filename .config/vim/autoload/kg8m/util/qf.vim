vim9script

import autoload "kg8m/plugin/fzf/qf.vim" as fzfQf
import autoload "kg8m/util/cursor.vim" as cursorUtil
import autoload "kg8m/util/input.vim" as inputUtil
import autoload "kg8m/util/logger.vim"

export const DIRPATH = $"{$XDG_DATA_HOME}/vim/qf"
export const EXTENSION = "json"

mkdir(DIRPATH, "p")

export def List(options: dict<bool> = {}): list<string>
  const colorize = get(options, "colorize", true)
  const command = [
    "fd",
    $FD_DEFAULT_OPTIONS,
    "--strip-cwd-prefix",
    "--type", "f",
    "--base-directory", shellescape(DIRPATH),
    "--extension", EXTENSION,
    "--color", colorize ? "always" : "never",
    "| sort_without_escape_sequences",
  ]->join(" ")

  return system(command)
    ->split("\n")
    ->map((_, filepath) => fnamemodify(filepath, ":t:r"))
enddef

export def Complete(arglead: string, _cmdline: string, _curpos: number): list<string>
  const all = List({ colorize: false })

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
    logger.Error("Quickfix list is empty. Do nothing.")
    return
  endif

  const filepath = NameToFilepath(
    empty(name) ? strftime("%Y%m%dT%H%M%S") : name
  )

  if filereadable(filepath)
    const prompt = $"`{filepath}` exists. Overwrite it?"

    if inputUtil.Confirm(prompt)
      redraw
    else
      redraw
      echo "Canceled."
      return
    endif
  endif

  const encoded_list = EncodeList(raw_list)
  writefile(encoded_list, filepath)

  logger.Info($"Quickfix list is saved to `{filepath}`.")
enddef

export def Load(name: string = ""): void
  if empty(name)
    fzfQf.Load()
  else
    Process(name, (filepath) => {
      const encoded_list = readfile(filepath)
      const decoded_list = DecodeList(encoded_list)

      execute "edit" fnameescape(decoded_list[0].filename)
      cursorUtil.MoveIntoFolding(decoded_list[0].lnum, decoded_list[0].col)

      setqflist(decoded_list)
      copen
      wincmd p
    })
  endif
enddef

export def Edit(name: string = ""): void
  if empty(name)
    fzfQf.Edit()
  else
    Process(name, (filepath) => {
      execute "edit" fnameescape(filepath)
    })
  endif
enddef

export def Delete(name: string = ""): void
  if empty(name)
    fzfQf.Delete()
  else
    Process(name, (filepath) => {
      const prompt = $"Sure to delete `{filepath}`?"

      if inputUtil.Confirm(prompt)
        delete(filepath)
        logger.Info($"`{filepath}` has been deleted.")
      else
        logger.Info($"`{filepath}` remains.")
      endif
    })
  endif
enddef

def Process(name: string, Callback: func(string)): void
  const filepath = NameToFilepath(name)

  if filereadable(filepath)
    Callback(filepath)
  else
    logger.Error($"`{filepath}` doesn't exist.")
  endif
enddef

def NameToFilepath(name: string): string
  return $"{DIRPATH}/{name}.{EXTENSION}"
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
