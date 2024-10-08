vim9script

import autoload "kg8m/configure/folding/manual.vim" as manualFolding
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/string.vim" as stringUtil

export const SESSIONS_BASEDIR_PATH = $"{$XDG_DATA_HOME}/vim/sessions"

# Use a prefix for names starting with a dot (.), that is hidden from Startify session files list.
const SESSION_FILENAME_FORMAT = "session:%s"

export def OnSource(): void
  Setup()
enddef

export def OnPostSource(): void
  OverwriteColors()
enddef

export def Setup(): void
  set sessionoptions=buffers,folds

  g:startify_session_autoload    = false
  g:startify_session_dir         = SessionsDirpath()
  g:startify_session_number      = 10
  g:startify_session_persistence = false
  g:startify_session_sort        = true

  g:startify_enable_special = true
  g:startify_change_to_dir  = false
  g:startify_relative_path  = true
  g:startify_lists          = [
    { type: "commands",  header: ["My commands:"] },
    { type: "bookmarks", header: ["My bookmarks:"] },
    { type: "sessions",  header: ["My sessions:"] },
    { type: "files",     header: ["Recently opened files:"] },
    { type: "dir",       header: ["Recently modified files in the current directory:"] },
  ]
  g:startify_commands = [
    { p: "call kg8m#plugin#update#All()" },
    { P: "call kg8m#plugin#update#All(#{ bulk: v:false })" },
  ]

  # https://gist.github.com/SammysHP/5611986#file-gistfile1-txt
  g:startify_custom_header = [
    "                      .",
    "      ##############..... ##############",
    "      ##############......##############",
    "        ##########..........##########",
    "        ##########........##########",
    "        ##########.......##########",
    "        ##########.....##########..",
    "        ##########....##########.....",
    "      ..##########..##########.........",
    "    ....##########.#########.............",
    "      ..################JJJ............",
    "        ################.............",
    "        ##############.JJJ.JJJJJJJJJJ",
    "        ############...JJ...JJ..JJ  JJ",
    "        ##########....JJ...JJ..JJ  JJ",
    "        ########......JJJ..JJJ JJJ JJJ",
    "        ######    .........",
    "                    .....",
    "                      .",
  ]

  g:startify_custom_header += [
    "",
    "",
    "  Vim version: " .. v:versionlong,
    "",
  ]

  g:startify_skiplist = [
    $'\V\^{SESSIONS_BASEDIR_PATH}/\.\+/{SessionFilename("")}',
  ]

  augroup vimrc-plugin-startify
    autocmd!
    autocmd FileType startify setlocal cursorline cursorlineopt=both
    autocmd ColorScheme  *    OverwriteColors()
    autocmd BufWritePost *    SaveSession()
    autocmd VimLeavePre  *    DeleteLastSessionLink()
  augroup END
enddef

export def SessionFilename(target_filepath: string = fileUtil.CurrentRelativePath()): string
  const sanitized_filepath = target_filepath->substitute("/", "+=", "g")
  return printf(SESSION_FILENAME_FORMAT, sanitized_filepath)
enddef

export def AddToSessionSavevar(varname: string): void
  if !has_key(g:, "startify_session_savevars")
    g:startify_session_savevars = []
  endif

  if !listUtil.Includes(g:startify_session_savevars, varname)
    add(g:startify_session_savevars, varname)
  endif
enddef

def OverwriteColors(): void
  highlight StartifyFile   guifg=#FFFFFF
  highlight StartifyHeader guifg=#FFFFFF
  highlight StartifyPath   guifg=#777777
  highlight StartifySlash  guifg=#777777
enddef

def SessionsDirpath(): string
  const sanitized_dirname = getcwd()->substitute("/", "=+", "g")
  return $"{SESSIONS_BASEDIR_PATH}/{sanitized_dirname}"
enddef

def SaveSession(): void
  manualFolding.Restore()

  if SessionSavable()
    mkdir(g:startify_session_dir, "p")

    try
      execute "silent SSave!" SessionFilename()
    # Temporary directories are sometimes deleted, e.g., after updating Vim.
    catch /E282: Cannot read from/
      const filepath = matchstr(v:exception, '\vE282: Cannot read from "\zs.+\ze"$')
      const dirpath  = fnamemodify(filepath, ":h")

      kg8m#util#logger#Warn(
        $"A temporary directory `{dirpath}` isn’t available now. Restarting Vim process is recommended."
      )
    endtry
  endif
enddef

def SessionSavable(): bool
  if &filetype ==# ""
    const filename = expand("%:t")

    if stringUtil.StartsWith(filename, "mmv-")
      return false
    else
      return true
    endif
  else
    return true
  endif
enddef

def DeleteLastSessionLink(): void
  const filepath = $"{g:startify_session_dir}/__LAST__"

  # Don’t use `filereadable(filepath)` because it returns FALSE if the symlink is broken.
  if !empty(glob(filepath, false, false, true))
    delete(filepath)
  endif
enddef
