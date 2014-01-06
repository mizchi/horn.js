# from Backbone.Events

# Regular expression used to split event strings.
eventSplitter = /\s+/;

# Utils
array = []
push = array.push
slice = array.slice
splice = array.splice

# https://github.com/jashkenas/underscore/blob/master/underscore.js#L743
_once = (func) ->
  ran = false
  memo = null
  ->
    if ran then return memo;
    ran = true
    memo = func.apply(this, arguments);
    func = null
    memo

# Implement fancy features of the Events API such as multiple event
# names `"change blur"` and jQuery-style event maps `{change: action}`
# in terms of the existing API.
eventsApi = (obj, action, name, rest) ->
  if not name then return true

  # Handle event maps.
  if (typeof name is 'object')
    for key of name
      obj[action].apply(obj, [key, name[key]].concat(rest))
    return false

  # Handle space separated event names.
  if eventSplitter.test(name)
    names = name.split(eventSplitter)
    for i in [0...names.length]
      obj[action].apply obj, [names[i]].concat(rest)
    return false
  return true

# A difficult-to-believe, but optimized internal dispatch function for
# triggering events. Tries to keep the usual cases speedy (most internal
# Backbone events have 3 arguments).
triggerEvents = (events, args) ->
  ev - undefined
  i = -1
  l = events.length
  a1 = args[0]
  a2 = args[1]
  a3 = args[2]
  switch args.length
    when 0 then while (++i < l) then (ev = events[i]).callback.call(ev.ctx)
    when 1 then while (++i < l) then (ev = events[i]).callback.call(ev.ctx, a1)
    when 2 then while (++i < l) then (ev = events[i]).callback.call(ev.ctx, a1, a2)
    when 3 then while (++i < l) then (ev = events[i]).callback.call(ev.ctx, a1, a2, a3)
    else while (++i < l) then (ev = events[i]).callback.apply(ev.ctx, args)

Events = Horn.Utils.Events =
  on: (name, callback, context) ->
    if not eventsApi(@, 'on', name, [callback, context]) or not callback
      return @
    @_events or (@_events = {})
    events = @_events[name] or (@_events[name] = [])
    events.push({callback: callback, context: context, ctx: context or this})
    @

  # Bind an event to only be triggered a single time. After the first time
  # the callback is invoked, it will be removed.

  once: (name, callback, context) ->
    if (not eventsApi(this, 'once', name, [callback, context]) or not callback)
      return @

    self = this
    once = _once ->
      self.off(name, once)
      callback.apply(this, arguments)

    once._callback = callback
    return @on(name, once, context)

  # Remove one or many callbacks. If `context` is null, removes all
  # callbacks with that function. If `callback` is null, removes all
  # callbacks for the event. If `name` is null, removes all bound
  # callbacks for all events.
  off: (name, callback, context) ->
    # retain, ev, events, names, i, l, j, k
    if not @_events or not eventsApi(this, 'off', name, [callback, context])
      return this
    if not name and not callback and not context
      @_events = undefined
      return this

    names = if name then [name] else Object.keys(@_events)
    for i in [0...names.length]
      name = names[i]
      if events = @_events[name]
        @_events[name] = retain = []
        if callback or context
          k = events.length
          j = 0
          while j < k
            ev = events[j]
            if ((callback and callback isnt ev.callback and callback isnt ev.callback._callback) or \
                (context and context isnt ev.context))
              retain.push(ev)
            j++
        if (not retain.length) then delete @_events[name]
    return @

  # Trigger one or many events, firing all bound callbacks. Callbacks are
  # passed the same arguments as `trigger` is, apart from the event name
  # (unless you're listening on `"all"`, which will cause your callback to
  # receive the true name of the event as the first argument).
  trigger: (name) ->
    if not @_events
      return this
    args = slice.call(arguments, 1)
    if (not eventsApi(this, 'trigger', name, args)) then return this
    events = @_events[name]
    allEvents = @_events.all
    if (events) then triggerEvents(events, args)
    if (allEvents) then triggerEvents(allEvents, arguments)
    @

  # Tell this object to stop listening to either specific events ... or
  # to every object it's currently listening to.
  stopListening: (obj, name, callback) ->
    listeningTo = @_listeningTo
    if (not listeningTo) then return this
    remove = not name and not callback
    if (not callback and (typeof name) is 'object') then callback = this
    if (obj) then (listeningTo = {})[obj._listenId] = obj
    for id in listeningTo
      obj = listeningTo[id]
      obj.off(name, callback, this)
      if (remove or _.isEmpty(obj._events)) then delete @_listeningTo[id]
    @
    return this

listenMethods = listenTo: 'on', listenToOnce: 'once'

# Inversion-of-control versions of `on` and `once`. Tell *this* object to
# listen to an event in another object ... keeping track of what it's
# listening to.

# for implementation, method of listenMethods then do (implementation, method) ->
for method, implementation of listenMethods then do (implementation, method) ->
  Events[method] = (obj, name, callback) ->
    listeningTo = (@_listeningTo ?= {})
    id = obj._listenId or (obj._listenId = _.uniqueId('l'))
    listeningTo[id] = obj
    if not callback and (typeof name) is 'object' then callback = @
    obj[implementation](name, callback, this)
    @
