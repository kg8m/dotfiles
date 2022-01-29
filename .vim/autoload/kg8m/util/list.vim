vim9script

final s:cache = {}

def kg8m#util#list#vital(): dict<func>
  if has_key(s:cache, "vital")
    return s:cache.vital
  endif

  s:cache.vital = vital#vital#import("Data.List")
  return s:cache.vital
enddef

def kg8m#util#list#includes(list: list<any>, item: any): bool
  return index(list, item) >=# 0
enddef

def kg8m#util#list#any(list: list<any>, Callback: func): bool
  for item in list
    if Callback(item)
      return true
    endif
  endfor

  return false
enddef

def kg8m#util#list#filter_map(list: list<any>, Callback: func): list<any>
  var result = []

  for item in list
    const new_item = Callback(item)

    if type(new_item) !=# type(false) || new_item !=# false
      result += [new_item]
    endif
  endfor

  return result
enddef
