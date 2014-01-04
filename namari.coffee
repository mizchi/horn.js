# utils
extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

# global name
window.hymn = ->
hymn.templates = {}
hymn.registerTemplate = (str) ->
  $el = $(str).eq(0)
  name = $el.data('template-name')
  throw "data-template-name is not defined" unless name
  hymn.templates[name] = $el
  return

hymn.directives = {}
hymn.addDirective = (name, fn) ->
  hymn.directives[name] = fn

hymn.addDirective "data-text", (view) ->
  for attr in view.attrs then do (attr) =>
    $el = view._$("[data-text=#{attr}]")
    view.on "change:#{attr}", => $el.text view[attr]

hymn.addDirective "data-click", (view) ->
  $el = view._$("[data-click]")
  $el.on 'click', (e) =>
    funcName = $(e.target).data('click')
    do view[funcName]

hymn.addDirective "data-visible", (view) ->
  for attr in view.attrs then do (attr) =>
    $els = view._$("[data-visible=#{attr}]")
    do update = ->
      $els.each (index) ->
        $el = $(@)
        if view[attr] then $el.show() else $el.hide()
    view.on "change:#{attr}", update

hymn.addDirective "data-click-with-trigger", (view) ->
  $el = view._$("[data-click-with-trigger]")
  $el.on 'click', (e) =>
    eventName = $(e.target).data('click-with-trigger')
    view.trigger eventName

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

class hymn.View
  extend @prototype, Querified
  extend @prototype, Dispatchable
  extend @prototype, Removable

  constructor: ->
    @$el = hymn.templates[@templateName].clone()
    @attrs = @$el.data('attrs').replace(/\s/g, '').split(',')
    for attr in @attrs then @property attr
    for name, func of hymn.directives then func @

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

hymn.registerTemplate """
  <div
    data-template-name="my-status"
    data-attrs="name, money, showAddMoney">

    <span data-text="name">NO NAME</span>
    <span data-text="money">0</span>
    <button data-click-with-trigger="update">update</button>
    <button data-click="toggleShowAddMoney">toggle show add money</button>
    <button data-visible="showAddMoney" data-click="addMoney">addMoney</button>
  </div>
"""

class MyStatus extends hymn.View
  templateName: 'my-status'
  addMoney: ->
    @money += 10

  toggleShowAddMoney: ->
    @showAddMoney = !@showAddMoney

$ ->
  window.a = new MyStatus
  a.attach 'body'
  a.on 'update', -> console.log 'updated'
  # a.hoge.text 'fuga'

