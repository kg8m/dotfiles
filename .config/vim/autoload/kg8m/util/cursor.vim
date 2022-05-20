vim9script

# Wrap `cursor()` and execute `doautocmd CursorMoved` because built-in `cursor()` doesn't trigger `CursorMoved` event.
export def Move(lnum: number, col: number): void
  cursor(lnum, col)
  doautocmd <nomodeline> CursorMoved
enddef
