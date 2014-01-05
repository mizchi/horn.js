Horn.Traits.Querified =
  css: -> @$el.css arguments...
  selectorCss: (selector, args...) -> @$(selector).css args...
  cssProperty: (key, propertyName) ->
    propertyName ?= key
    Object.defineProperty @, key,
      get: -> @css(propertyName)
      set: (v) -> @css propertyName, v

  $: (selector) -> @$el.find(selector)
  _$: (selector) ->
    @_local_cache ?= {}
    @_local_cache[selector] ?= @$(selector)

  show: -> @$el.show()

  hide: -> @$el.hide()

  remove: -> @$el.remove()

  html: -> @$el.html arguments...

  text: -> @$el.text arguments...
