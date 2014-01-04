window.Horn = ->
Horn.Utils = {}
Horn.Traits = {}

# utils
Horn.Utils.extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj
