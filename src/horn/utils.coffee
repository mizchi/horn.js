# utils
Horn.Utils.extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

Horn.Utils.parseObjectiveLiteral = (str)->
  obj = {}
  for key in str.replace(/\s|\n/g, '').split(',')
    [key, val] = key.split(':')
    obj[key] = val
  obj
