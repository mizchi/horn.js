# === Traits ===
Horn.Traits.Dispatchable =
  trigger: -> @$el.trigger arguments...

  publish: (event, args...) -> @$el.trigger(event, args)

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
