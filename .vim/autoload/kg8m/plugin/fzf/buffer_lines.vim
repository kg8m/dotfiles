vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Show preview around each line (Fzf's `:BLines` doesn't show preview)
def kg8m#plugin#fzf#buffer_lines#run(query: string = ""): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(query),
    "sink*": function("s:handler"),
    options: [
      "--nth", "2..",
      "--prompt", "BufferLines> ",
      "--tabstop", "1",
      "--preview", printf("$FZF_VIM_PATH/bin/preview.sh %s:{1}", expand("%")->shellescape()),
      "--preview-window", "down:50%:wrap:nohidden:+{1}-/2",
    ],
  }

  fzf#run(fzf#wrap("buffer-lines", options))
enddef

# https://github.com/junegunn/fzf.vim/blob/0452b71830b1a219b8cdc68141ee58ec288ea711/autoload/fzf/vim.vim#L481-L489
def s:candidates(query: string): list<string>
  const lines = getline(1, "$")
  const Mapper = (index, line) => printf(" %4d \t%s", index + 1, line)

  if empty(query)
    return lines->mapnew(Mapper)
  else
    var i = -1
    return lines->kg8m#util#list#filter_map((line): any => {
      i += 1

      if line =~# query
        return Mapper(i, line)
      else
        return false
      endif
    })
  endif
enddef

# https://github.com/junegunn/fzf.vim/blob/0452b71830b1a219b8cdc68141ee58ec288ea711/autoload/fzf/vim.vim#L459-L479
def s:handler(lines: list<string>): void
  const filepath = expand("%")
  const Mapper = (_, line) => {
    const chunks = split(line, "\t", 1)
    const linenr = str2nr(chunks[0])
    const text   = join(chunks[1 : ], "\t")

    return { filename: filepath, lnum: linenr, text: text }
  }

  lines->mapnew(Mapper)->setqflist()

  copen
  wincmd p
  cfirst
  normal! m'

  execute ":" .. split(lines[0], "\t")[0]
  normal! ^zvzz
enddef
