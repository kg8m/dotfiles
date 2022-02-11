vim9script

# Copy `Foo::Bar::Baz` from
#
#   module Foo
#     class Bar
#       module Baz
#       end
#     end
#   end
#
# https://github.com/ujihisa/config/blob/dc95c0a8b8be6722a98dd9acd916271fa507d25d/_vimrc#L2921-L2931
export def CopyNestedClassName(): void
  const PATTERN = '\v^\s*(class|module)\s+\zs(\k|[:])+'

  final lines = getline("'<", "'>")
  const name  = lines->map((_, line) => matchstr(line, PATTERN))->filter((_, line) => line !=# "")->join("::")

  if empty(name)
    kg8m#util#logger#Warn("No class/module name found in selected text.")
  else
    kg8m#util#RemoteCopy(name)
  endif
enddef
