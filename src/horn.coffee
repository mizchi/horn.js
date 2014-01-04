# utils
extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

# global name
window.Horn = ->
Horn.templates = {}
Horn.registerTemplate = (str) ->
  $el = $(str).eq(0)
  name = $el.data('template-name')
  throw "data-template-name is not defined" unless name
  Horn.templates[name] = $el
  return

Horn.directives = {}
Horn.addDirective = (name, fn) ->
  Horn.directives[name] = fn

Horn.addDirective "data-text", (view) ->
  for attr in view.attrs then do (attr) =>
    $el = view._$("[data-text=#{attr}]")
    view.on "change:#{attr}", => $el.text view[attr]

Horn.addDirective "data-click", (view) ->
  $el = view._$("[data-click]")
  $el.on 'click', (e) =>
    funcName = $(e.target).data('click')
    do view[funcName]

Horn.addDirective "data-visible", (view) ->
  for attr in view.attrs then do (attr) =>
    $els = view._$("[data-visible=#{attr}]")
    do update = ->
      $els.each (index) ->
        $el = $(@)
        if view[attr] then $el.show() else $el.hide()
    view.on "change:#{attr}", update

Dispatchable =
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

Querified =
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

Removable =
  attach: (selector, container = null)->
    if arguments.length is 1 and selector.$el?
      selector.$el.append @$el
    else if container?.$?
      container.$(selector).append @$el
    else
      $(selector).append @$el

  detach: ->
    @$el.detach()

class Horn.View
  extend @prototype, Querified
  extend @prototype, Dispatchable
  extend @prototype, Removable

  constructor: ->
    @$el = Horn.templates[@templateName].clone()
    @attrs = @$el.data('attrs').replace(/\s/g, '').split(',')
    for attr in @attrs then @property attr
    for name, func of Horn.directives then func @

  property: (key) ->
    orig = @[key]
    delete @[key]
    Object.defineProperty @, key,
      enumerable: false
      get: -> @['_' + key]
      set: (v) ->
        if v isnt @['_'+key]
          @['_' + key] = v
          @trigger "change:#{key}"
    @['_'+key] = orig ? null

class Horn.ListView
  extend @prototype, Querified
  extend @prototype, Dispatchable
  extend @prototype, Removable
  className: 'div'

  itemView: Horn.View
  constructor: ->
    @$el = $("<#{@className}>")
    @views = []

  addItem: (item = {}) ->
    view = new @itemView
    for k, v of item
      view[k] = v
    @views.push view
    view.attach @

  size: (n) ->
    return @views.length unless n?

    if @views.length > n
      for i in [1..@views.length-n]
        @views.pop().remove()

    else if @views.length < n
      for i in [1..n-@views.length]
        @addItem()

  get: (n) -> @views[n]

  toJSON: ->
    for view, index in @views
      item = {}
      for key in view.attrs
        item[key] = view[key]
      item

  update: (items) ->
    if items.length isnt @views.length then @size items.length

    for view, index in @views
      item = items[index]
      console.log item
      for key in view.attrs when item[key]?
        view[key] = item[key]
    return
