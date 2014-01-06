{extend} = Horn.Utils
# View class
class Horn.View
  extend @prototype, Horn.Traits.Events
  extend @prototype, Horn.Traits.Querified
  extend @prototype, Horn.Traits.Removable

  constructor: ->
    @$el = Horn.templates[@templateName].clone()
    @attrs = @$el.data('attrs').replace(/\s/g, '').split(',')
    for attr in @attrs then @property attr

    # reject unused directive
    for name, func of Horn.directives when Horn.raw_templates[@templateName].indexOf(name) > -1
      func @

  dispose: ->
    if @parent? then @parent.trigger 'child:disposed', @
    @disposed = true
    @remove()

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
          if @parent? then @parent.trigger 'child:changed', @

    @['_'+key] = orig ? null
