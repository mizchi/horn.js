{extend} = Horn.Utils

Horn.templates = {}
Horn.raw_templates = {}
Horn.registerTemplate = (str) ->
  $el = $(str).eq(0)
  name = $el.data('template-name')
  throw "data-template-name is not defined" unless name
  Horn.templates[name] = $el
  Horn.raw_templates[name] = str

Horn.directives = {}
Horn.addDirective = (name, fn) ->
  Horn.directives[name] = fn

Horn.addDirectiveByEachElement = (name, fn) ->
  Horn.directives[name] = (view) ->
    $el = view.$("[#{name}]")
    $el.each (index) ->
      $el = $(@)
      val = $el.attr(name)
      fn view, $el, val

Horn.addDirectiveByEachValue = (name, fn) ->
  Horn.directives[name] = (view) ->
    for attr in view.attrs then do (attr) =>
      $el = view._$("[#{name}=#{attr}]")
      fn view, $el, attr

# === Defaut Directives ===
Horn.addDirectiveByEachValue "data-text", (view, $el, val) ->
  view.on "change:#{val}", => $el.text view[val]

Horn.addDirectiveByEachElement "data-click", (view, $el, val) ->
  $el.on 'click', (view[val].bind view)

Horn.addDirective "data-visible", (view) ->
  for attr in view.attrs then do (attr) =>
    $els = view._$("[data-visible=#{attr}]")
    do update = ->
      $els.each (index) ->
        $el = $(@)
        if view[attr] then $el.show() else $el.hide()
    view.on "change:#{attr}", update

Horn.addDirectiveByEachElement "data-view", (view, $el, val) ->
  viewNames = view.$el.attr('data-views').replace(/\s/g, '').split(',')
  data = do ->
    obj = {}
    for key in val.replace(/\s|\n/g, '').split(',')
      [key, val] = key.split(':')
      obj[key] = val
    obj

  for templateName, propertyName of data
    Cls = view.viewClassMapping[templateName]()
    cv = new Cls
    cv.attach $el
    view[propertyName] = cv

Horn.addDirectiveByEachElement "data-list-view", (view, $el, val) ->
  viewNames = view.$el.attr('data-views').replace(/\s/g, '').split(',')
  data = do ->
    obj = {}
    for key in val.replace(/\s|\n/g, '').split(',')
      [key, val] = key.split(':')
      obj[key] = val
    obj

  for templateName, propertyName of data
    Cls = view.viewClassMapping[templateName]()
    cv = new class extends Horn.ListView
      itemView: Cls
    cv.attach $el
    view[propertyName] = cv
