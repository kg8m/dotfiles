vim9script

final cache = {}

export def Vital(): dict<func>
  if has_key(cache, "vital")
    return cache.vital
  endif

  cache.vital = vital#vital#import("Data.List")
  return cache.vital
enddef

export def Includes(list: list<any>, item: any): bool
  return index(list, item) >=# 0
enddef

export def Any(list: list<any>, Callback: func(any): bool = (item) => !!item): bool
  for item in list
    if Callback(item)
      return true
    endif
  endfor

  return false
enddef

export def All(list: list<any>, Callback: func(any): bool = (item) => !!item): bool
  for item in list
    if !Callback(item)
      return false
    endif
  endfor

  return true
enddef

export def Union(list1: list<any>, list2: list<any>, Callback: func(any): any = (item) => item): list<any>
  const indexed_list1 = IndexBy(list1, (item) => Callback(item))
  const filtered_list2 = list2->copy()->filter((_, item) => !has_key(indexed_list1, Callback(item)))

  return list1 + filtered_list2
enddef

export def FilterMap(list: list<any>, Callback: func(any): any): list<any>
  return reduce(list, (result, item) => {
    const new_item = Callback(item)

    if type(new_item) !=# type(false) || new_item !=# false
      add(result, new_item)
    endif

    return result
  }, [])
enddef

export def IndexBy(list: list<any>, Callback: func(any): any): dict<any>
  return reduce(list, (result, item) => {
    result[Callback(item)] = item
    return result
  }, {})
enddef
