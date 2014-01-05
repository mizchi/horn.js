{extend} = Horn.Utils

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

# === Defaut Directives ===
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
