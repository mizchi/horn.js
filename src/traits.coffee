# === Traits ===
Horn.Traits.Dispatchable =
  trigger: -> @$el.trigger arguments...

  on: -> @$el.on arguments...

  off: -> @$el.off arguments...

  # expect Backbone.Model
  observe: (first, second, third) ->
    if (typeof third) is 'function'
      model = first
      key = first
      callback = third
    else if @model?
      model = @model
      key = first
      callback = second
    else
      throw 'invalid observe target'
    model.on "change:#{key}", callback

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

Horn.Traits.Removable =
  attach: (selector, container = null)->
    if arguments.length is 1 and selector.$el?
      selector.$el.append @$el
    else if container?.$?
      container.$(selector).append @$el
    else
      $(selector).append @$el

  detach: ->
    @$el.detach()

