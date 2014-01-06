(function() {
  var E, Events, array, eventSplitter, eventsApi, extend, implementation, listenMethods, method, push, slice, splice, triggerEvents, _fn, _fn1, _once,
    __slice = [].slice;

  window.Horn = function() {};

  Horn.Utils = {};

  Horn.Traits = {};

  Horn.Utils.extend = function(obj, mixin) {
    var method, name;
    for (name in mixin) {
      method = mixin[name];
      obj[name] = method;
    }
    return obj;
  };

  Horn.Traits.Dispatchable = {
    trigger: function() {
      var _ref;
      return (_ref = this.$el).trigger.apply(_ref, arguments);
    },
    publish: function() {
      var args, event;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.$el.trigger(event, args);
    },
    on: function() {
      var _ref;
      return (_ref = this.$el).on.apply(_ref, arguments);
    },
    off: function() {
      var _ref;
      return (_ref = this.$el).off.apply(_ref, arguments);
    },
    observe: function(first, second, third) {
      var callback, key, model;
      if ((typeof third) === 'function') {
        model = first;
        key = first;
        callback = third;
      } else if (this.model != null) {
        model = this.model;
        key = first;
        callback = second;
      } else {
        throw 'invalid observe target';
      }
      return model.on("change:" + key, callback);
    }
  };

  eventSplitter = /\s+/;

  array = [];

  push = array.push;

  slice = array.slice;

  splice = array.splice;

  _once = function(func) {
    var memo, ran;
    ran = false;
    memo = null;
    return function() {
      if (ran) {
        return memo;
      }
      ran = true;
      memo = func.apply(this, arguments);
      func = null;
      return memo;
    };
  };

  eventsApi = function(obj, action, name, rest) {
    var i, key, names, _i, _ref;
    if (!name) {
      return true;
    }
    if (typeof name === 'object') {
      for (key in name) {
        obj[action].apply(obj, [key, name[key]].concat(rest));
      }
      return false;
    }
    if (eventSplitter.test(name)) {
      names = name.split(eventSplitter);
      for (i = _i = 0, _ref = names.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        obj[action].apply(obj, [names[i]].concat(rest));
      }
      return false;
    }
    return true;
  };

  triggerEvents = function(events, args) {
    var a1, a2, a3, ev, i, l, _results, _results1, _results2, _results3, _results4;
    ev - void 0;
    i = -1;
    l = events.length;
    a1 = args[0];
    a2 = args[1];
    a3 = args[2];
    switch (args.length) {
      case 0:
        _results = [];
        while (++i < l) {
          _results.push((ev = events[i]).callback.call(ev.ctx));
        }
        return _results;
        break;
      case 1:
        _results1 = [];
        while (++i < l) {
          _results1.push((ev = events[i]).callback.call(ev.ctx, a1));
        }
        return _results1;
        break;
      case 2:
        _results2 = [];
        while (++i < l) {
          _results2.push((ev = events[i]).callback.call(ev.ctx, a1, a2));
        }
        return _results2;
        break;
      case 3:
        _results3 = [];
        while (++i < l) {
          _results3.push((ev = events[i]).callback.call(ev.ctx, a1, a2, a3));
        }
        return _results3;
        break;
      default:
        _results4 = [];
        while (++i < l) {
          _results4.push((ev = events[i]).callback.apply(ev.ctx, args));
        }
        return _results4;
    }
  };

  Events = Horn.Events = {
    on: function(name, callback, context) {
      var events;
      if (!eventsApi(this, 'on', name, [callback, context]) || !callback) {
        return this;
      }
      this._events || (this._events = {});
      events = this._events[name] || (this._events[name] = []);
      events.push({
        callback: callback,
        context: context,
        ctx: context || this
      });
      return this;
    },
    once: function(name, callback, context) {
      var once, self;
      if (!eventsApi(this, 'once', name, [callback, context]) || !callback) {
        return this;
      }
      self = this;
      once = _once(function() {
        self.off(name, once);
        return callback.apply(this, arguments);
      });
      once._callback = callback;
      return this.on(name, once, context);
    },
    off: function(name, callback, context) {
      var ev, events, i, j, k, names, retain, _i, _ref;
      if (!this._events || !eventsApi(this, 'off', name, [callback, context])) {
        return this;
      }
      if (!name && !callback && !context) {
        this._events = void 0;
        return this;
      }
      names = name ? [name] : Object.keys(this._events);
      for (i = _i = 0, _ref = names.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        name = names[i];
        if (events = this._events[name]) {
          this._events[name] = retain = [];
          if (callback || context) {
            k = events.length;
            j = 0;
            while (j < k) {
              ev = events[j];
              if ((callback && callback !== ev.callback && callback !== ev.callback._callback) || (context && context !== ev.context)) {
                retain.push(ev);
              }
              j++;
            }
          }
          if (!retain.length) {
            delete this._events[name];
          }
        }
      }
      return this;
    },
    trigger: function(name) {
      var allEvents, args, events;
      if (!this._events) {
        return this;
      }
      args = slice.call(arguments, 1);
      if (!eventsApi(this, 'trigger', name, args)) {
        return this;
      }
      events = this._events[name];
      allEvents = this._events.all;
      if (events) {
        triggerEvents(events, args);
      }
      if (allEvents) {
        triggerEvents(allEvents, arguments);
      }
      return this;
    },
    stopListening: function(obj, name, callback) {
      var id, listeningTo, remove, _i, _len;
      listeningTo = this._listeningTo;
      if (!listeningTo) {
        return this;
      }
      remove = !name && !callback;
      if (!callback && (typeof name) === 'object') {
        callback = this;
      }
      if (obj) {
        (listeningTo = {})[obj._listenId] = obj;
      }
      for (_i = 0, _len = listeningTo.length; _i < _len; _i++) {
        id = listeningTo[_i];
        obj = listeningTo[id];
        obj.off(name, callback, this);
        if (remove || _.isEmpty(obj._events)) {
          delete this._listeningTo[id];
        }
      }
      this;
      return this;
    }
  };

  listenMethods = {
    listenTo: 'on',
    listenToOnce: 'once'
  };

  _fn = function(implementation, method) {
    return Events[method] = function(obj, name, callback) {
      var id, listeningTo;
      listeningTo = (this._listeningTo != null ? this._listeningTo : this._listeningTo = {});
      id = obj._listenId || (obj._listenId = _.uniqueId('l'));
      listeningTo[id] = obj;
      if (!callback && (typeof name) === 'object') {
        callback = this;
      }
      obj[implementation](name, callback, this);
      return this;
    };
  };
  for (method in listenMethods) {
    implementation = listenMethods[method];
    _fn(implementation, method);
  }

  E = (function() {
    function E() {}

    Horn.Utils.extend(E.prototype, Events);

    return E;

  })();

  window.e = new E;

  e.on('hoge', function() {
    return console.log('hoge');
  });

  eventSplitter = /\s+/;

  array = [];

  push = array.push;

  slice = array.slice;

  splice = array.splice;

  _once = function(func) {
    var memo, ran;
    ran = false;
    memo = null;
    return function() {
      if (ran) {
        return memo;
      }
      ran = true;
      memo = func.apply(this, arguments);
      func = null;
      return memo;
    };
  };

  eventsApi = function(obj, action, name, rest) {
    var i, key, names, _i, _ref;
    if (!name) {
      return true;
    }
    if (typeof name === 'object') {
      for (key in name) {
        obj[action].apply(obj, [key, name[key]].concat(rest));
      }
      return false;
    }
    if (eventSplitter.test(name)) {
      names = name.split(eventSplitter);
      for (i = _i = 0, _ref = names.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        obj[action].apply(obj, [names[i]].concat(rest));
      }
      return false;
    }
    return true;
  };

  triggerEvents = function(events, args) {
    var a1, a2, a3, ev, i, l, _results, _results1, _results2, _results3, _results4;
    ev - void 0;
    i = -1;
    l = events.length;
    a1 = args[0];
    a2 = args[1];
    a3 = args[2];
    switch (args.length) {
      case 0:
        _results = [];
        while (++i < l) {
          _results.push((ev = events[i]).callback.call(ev.ctx));
        }
        return _results;
        break;
      case 1:
        _results1 = [];
        while (++i < l) {
          _results1.push((ev = events[i]).callback.call(ev.ctx, a1));
        }
        return _results1;
        break;
      case 2:
        _results2 = [];
        while (++i < l) {
          _results2.push((ev = events[i]).callback.call(ev.ctx, a1, a2));
        }
        return _results2;
        break;
      case 3:
        _results3 = [];
        while (++i < l) {
          _results3.push((ev = events[i]).callback.call(ev.ctx, a1, a2, a3));
        }
        return _results3;
        break;
      default:
        _results4 = [];
        while (++i < l) {
          _results4.push((ev = events[i]).callback.apply(ev.ctx, args));
        }
        return _results4;
    }
  };

  Events = Horn.Utils.Events = {
    on: function(name, callback, context) {
      var events;
      if (!eventsApi(this, 'on', name, [callback, context]) || !callback) {
        return this;
      }
      this._events || (this._events = {});
      events = this._events[name] || (this._events[name] = []);
      events.push({
        callback: callback,
        context: context,
        ctx: context || this
      });
      return this;
    },
    once: function(name, callback, context) {
      var once, self;
      if (!eventsApi(this, 'once', name, [callback, context]) || !callback) {
        return this;
      }
      self = this;
      once = _once(function() {
        self.off(name, once);
        return callback.apply(this, arguments);
      });
      once._callback = callback;
      return this.on(name, once, context);
    },
    off: function(name, callback, context) {
      var ev, events, i, j, k, names, retain, _i, _ref;
      if (!this._events || !eventsApi(this, 'off', name, [callback, context])) {
        return this;
      }
      if (!name && !callback && !context) {
        this._events = void 0;
        return this;
      }
      names = name ? [name] : Object.keys(this._events);
      for (i = _i = 0, _ref = names.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        name = names[i];
        if (events = this._events[name]) {
          this._events[name] = retain = [];
          if (callback || context) {
            k = events.length;
            j = 0;
            while (j < k) {
              ev = events[j];
              if ((callback && callback !== ev.callback && callback !== ev.callback._callback) || (context && context !== ev.context)) {
                retain.push(ev);
              }
              j++;
            }
          }
          if (!retain.length) {
            delete this._events[name];
          }
        }
      }
      return this;
    },
    trigger: function(name) {
      var allEvents, args, events;
      if (!this._events) {
        return this;
      }
      args = slice.call(arguments, 1);
      if (!eventsApi(this, 'trigger', name, args)) {
        return this;
      }
      events = this._events[name];
      allEvents = this._events.all;
      if (events) {
        triggerEvents(events, args);
      }
      if (allEvents) {
        triggerEvents(allEvents, arguments);
      }
      return this;
    },
    stopListening: function(obj, name, callback) {
      var id, listeningTo, remove, _i, _len;
      listeningTo = this._listeningTo;
      if (!listeningTo) {
        return this;
      }
      remove = !name && !callback;
      if (!callback && (typeof name) === 'object') {
        callback = this;
      }
      if (obj) {
        (listeningTo = {})[obj._listenId] = obj;
      }
      for (_i = 0, _len = listeningTo.length; _i < _len; _i++) {
        id = listeningTo[_i];
        obj = listeningTo[id];
        obj.off(name, callback, this);
        if (remove || _.isEmpty(obj._events)) {
          delete this._listeningTo[id];
        }
      }
      this;
      return this;
    }
  };

  listenMethods = {
    listenTo: 'on',
    listenToOnce: 'once'
  };

  _fn1 = function(implementation, method) {
    return Events[method] = function(obj, name, callback) {
      var id, listeningTo;
      listeningTo = (this._listeningTo != null ? this._listeningTo : this._listeningTo = {});
      id = obj._listenId || (obj._listenId = _.uniqueId('l'));
      listeningTo[id] = obj;
      if (!callback && (typeof name) === 'object') {
        callback = this;
      }
      obj[implementation](name, callback, this);
      return this;
    };
  };
  for (method in listenMethods) {
    implementation = listenMethods[method];
    _fn1(implementation, method);
  }

  E = (function() {
    function E() {}

    Horn.Utils.extend(E.prototype, Events);

    return E;

  })();

  window.e = new E;

  e.once('fuga', function() {
    console.log('fuga');
    return 1;
  });

  e.on('hoge', function(a) {
    return console.log('hoge', a);
  });

  e.trigger('hoge', 'year');

  e.trigger('fuga');

  e.trigger('fuga');

  Horn.Traits.Querified = {
    css: function() {
      var _ref;
      return (_ref = this.$el).css.apply(_ref, arguments);
    },
    selectorCss: function() {
      var args, selector, _ref;
      selector = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.$(selector)).css.apply(_ref, args);
    },
    cssProperty: function(key, propertyName) {
      if (propertyName == null) {
        propertyName = key;
      }
      return Object.defineProperty(this, key, {
        get: function() {
          return this.css(propertyName);
        },
        set: function(v) {
          return this.css(propertyName, v);
        }
      });
    },
    $: function(selector) {
      return this.$el.find(selector);
    },
    _$: function(selector) {
      var _base;
      if (this._local_cache == null) {
        this._local_cache = {};
      }
      return (_base = this._local_cache)[selector] != null ? (_base = this._local_cache)[selector] : _base[selector] = this.$(selector);
    },
    show: function() {
      return this.$el.show();
    },
    hide: function() {
      return this.$el.hide();
    },
    remove: function() {
      return this.$el.remove();
    },
    html: function() {
      var _ref;
      return (_ref = this.$el).html.apply(_ref, arguments);
    },
    text: function() {
      var _ref;
      return (_ref = this.$el).text.apply(_ref, arguments);
    }
  };

  Horn.Traits.Removable = {
    attach: function(selector, container) {
      if (container == null) {
        container = null;
      }
      if (arguments.length === 1 && (selector.$el != null)) {
        return selector.$el.append(this.$el);
      } else if ((container != null ? container.$ : void 0) != null) {
        return container.$(selector).append(this.$el);
      } else {
        return $(selector).append(this.$el);
      }
    },
    detach: function() {
      return this.$el.detach();
    }
  };

  extend = Horn.Utils.extend;

  Horn.templates = {};

  Horn.registerTemplate = function(str) {
    var $el, name;
    $el = $(str).eq(0);
    name = $el.data('template-name');
    if (!name) {
      throw "data-template-name is not defined";
    }
    Horn.templates[name] = $el;
  };

  Horn.directives = {};

  Horn.addDirective = function(name, fn) {
    return Horn.directives[name] = fn;
  };

  Horn.addDirective("data-text", function(view) {
    var attr, _i, _len, _ref, _results,
      _this = this;
    _ref = view.attrs;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      attr = _ref[_i];
      _results.push((function(attr) {
        var $el;
        $el = view._$("[data-text=" + attr + "]");
        return view.on("change:" + attr, function() {
          return $el.text(view[attr]);
        });
      })(attr));
    }
    return _results;
  });

  Horn.addDirective("data-click", function(view) {
    var $el,
      _this = this;
    $el = view._$("[data-click]");
    return $el.on('click', function(e) {
      var funcName;
      funcName = $(e.target).data('click');
      return view[funcName]();
    });
  });

  Horn.addDirective("data-visible", function(view) {
    var attr, _i, _len, _ref, _results,
      _this = this;
    _ref = view.attrs;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      attr = _ref[_i];
      _results.push((function(attr) {
        var $els, update;
        $els = view._$("[data-visible=" + attr + "]");
        (update = function() {
          return $els.each(function(index) {
            var $el;
            $el = $(this);
            if (view[attr]) {
              return $el.show();
            } else {
              return $el.hide();
            }
          });
        })();
        return view.on("change:" + attr, update);
      })(attr));
    }
    return _results;
  });

  extend = Horn.Utils.extend;

  Horn.View = (function() {
    extend(View.prototype, Horn.Traits.Querified);

    extend(View.prototype, Horn.Traits.Dispatchable);

    extend(View.prototype, Horn.Traits.Removable);

    function View() {
      var attr, func, name, _i, _len, _ref, _ref1;
      this.$el = Horn.templates[this.templateName].clone();
      this.attrs = this.$el.data('attrs').replace(/\s/g, '').split(',');
      _ref = this.attrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        this.property(attr);
      }
      _ref1 = Horn.directives;
      for (name in _ref1) {
        func = _ref1[name];
        func(this);
      }
    }

    View.prototype.dispose = function() {
      if (this.parent != null) {
        this.parent.publish('child:disposed', this);
      }
      this.disposed = true;
      return this.remove();
    };

    View.prototype.property = function(key) {
      var orig;
      orig = this[key];
      delete this[key];
      Object.defineProperty(this, key, {
        enumerable: false,
        get: function() {
          return this['_' + key];
        },
        set: function(v) {
          if (v !== this['_' + key]) {
            this['_' + key] = v;
            this.trigger("change:" + key);
            if (this.parent != null) {
              return this.parent.publish('child:changed', this);
            }
          }
        }
      });
      return this['_' + key] = orig != null ? orig : null;
    };

    return View;

  })();

  extend = Horn.Utils.extend;

  Horn.ListView = (function() {
    extend(ListView.prototype, Horn.Traits.Querified);

    extend(ListView.prototype, Horn.Traits.Dispatchable);

    extend(ListView.prototype, Horn.Traits.Removable);

    ListView.prototype.className = 'div';

    ListView.prototype.itemView = Horn.View;

    function ListView() {
      var _this = this;
      this.$el = $("<" + this.className + ">");
      this.views = [];
      this.on('child:disposed', function(e, view) {
        var data, rejectIndex;
        rejectIndex = _this.views.indexOf(view);
        data = _this.toJSON();
        data.splice(rejectIndex, 1);
        _this.views.splice(rejectIndex, 1);
        return _this.update(data);
      });
    }

    ListView.prototype.addItem = function(item) {
      var k, v, view;
      if (item == null) {
        item = {};
      }
      view = new this.itemView;
      view.parent = this;
      for (k in item) {
        v = item[k];
        view[k] = v;
      }
      this.views.push(view);
      return view.attach(this);
    };

    ListView.prototype.size = function(n) {
      var i, _i, _j, _ref, _ref1, _results, _results1;
      if (n == null) {
        return this.views.length;
      }
      if (this.views.length > n) {
        _results = [];
        for (i = _i = 1, _ref = this.views.length - n; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          _results.push(this.views.pop().remove());
        }
        return _results;
      } else if (this.views.length < n) {
        _results1 = [];
        for (i = _j = 1, _ref1 = n - this.views.length; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
          _results1.push(this.addItem());
        }
        return _results1;
      }
    };

    ListView.prototype.get = function(n) {
      return this.views[n];
    };

    ListView.prototype.toJSON = function() {
      var index, item, key, view, _i, _j, _len, _len1, _ref, _ref1, _results;
      _ref = this.views;
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        view = _ref[index];
        item = {};
        _ref1 = view.attrs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          key = _ref1[_j];
          item[key] = view[key];
        }
        _results.push(item);
      }
      return _results;
    };

    ListView.prototype.update = function(items) {
      var index, item, key, view, _i, _j, _len, _len1, _ref, _ref1;
      if (items.length !== this.views.length) {
        this.size(items.length);
      }
      _ref = this.views;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        view = _ref[index];
        item = items[index];
        _ref1 = view.attrs;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          key = _ref1[_j];
          if (item[key] != null) {
            view[key] = item[key];
          }
        }
      }
    };

    return ListView;

  })();

}).call(this);

/*
//# sourceMappingURL=../dist/horn.js.map
*/