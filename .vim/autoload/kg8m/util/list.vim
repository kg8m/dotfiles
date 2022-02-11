vim9script

final s:cache = {}

export def Vital(): dict<func>
  if has_key(s:cache, "vital")
    return s:cache.vital
  endif

  s:cache.vital = vital#vital#import("Data.List")
  return s:cache.vital
enddef

export def Includes(list: list<any>, item: any): bool
  return index(list, item) >=# 0
enddef

export def Any(list: list<any>, Callback: func(any): bool): bool
  for item in list
    if Callback(item)
      return true
    endif
  endfor

  return false
enddef

export def All(list: list<any>, Callback: func(any): bool): bool
  for item in list
    if !Callback(item)
      return false
    endif
  endfor

  return true
enddef

export def FilterMap(list: list<any>, Callback: func(any): any): list<any>
  var result = []

  for item in list
    const new_item = Callback(item)

    if type(new_item) !=# type(false) || new_item !=# false
      result += [new_item]
    endif
  endfor

  return result
enddef
