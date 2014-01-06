{extend} = Horn.Utils
# List View Class
class Horn.ListView
  extend @prototype, Horn.Traits.Events
  extend @prototype, Horn.Traits.Querified
  extend @prototype, Horn.Traits.Removable
  className: 'div'

  itemView: Horn.View
  constructor: ->
    @$el = $("<#{@className}>")
    @views = []

    @on 'child:disposed', (e, view) =>
      rejectIndex = @views.indexOf(view)

      data = @toJSON()
      data.splice(rejectIndex, 1)
      @views.splice(rejectIndex, 1)

      @update data

  addItem: (item = {}) ->
    view = new @itemView
    view.parent = @

    for k, v of item
      view[k] = v
    @views.push view
    view.attach @

  each: (f) ->
    @view.forEach f

  eachElement: (f) ->
    @view.forEach (v) -> f(v.$el)

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
      for key in view.attrs when item[key]?
        view[key] = item[key]
    return
