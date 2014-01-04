# Horn.js

Fast and  simple reactive view framework.
inspired by angular, backbone and knockout.

![](http://upload.wikimedia.org/wikipedia/commons/5/57/Narwal_brehm.jpg)

## Features

- angular like directive
- knockout like data-bind
- backbone like view API (coffee-script friendly)
- simple list view implementation
- less code, more powerful

## Requirements

- jQuery

## Install

User bower

```
$ bower install horn
```

## Example

```coffee-script

# Define custom directive
Horn.addDirective "data-click-with-trigger", (view) ->
  $el = view.$("[data-click-with-trigger]")
  $el.on 'click', (e) =>
    eventName = $(e.target).data('click-with-trigger')
    view.trigger eventName

# Register as raw string. This root need to have data-temaplate-name.
# Write your templates as your way.
Horn.registerTemplate """
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

# It extends Horn.View and binds template by templateName
class Status extends Horn.View
  templateName: 'my-status'
  addMoney: ->
    @money += 10 # data-attrs generate getters.
    # data-text='money' change view soon.

  toggleShowAddMoney: ->
    @showAddMoney = !@showAddMoney

# ListView has itemView
class StatusList extends Horn.ListView
  itemView: Status

$ ->
  # View
  status = new Status
  status.name = 'foo'
  status.money = 0

  # attach
  status.attach 'body'
  status.on 'update', -> console.log 'updated' # fired by custom directive

  # ListView
  list = new StatusList
  list.size(2) # generate automatically 2 blank view.
  list.update [{name: 1},{name: 2},{name: 3}] # generate automatically 3 view and apply params.
  list.addItem {name: 4} # add more
  list.attach 'body'
```

See detail at examples.

# API

## Horn

Create your own directive via `Horn.addDirective`

Default has Knockout like API.

- data-text
- data-click
- data-visible

## Horn.View

Backbone like API

- View#$(selector)
- View#_$(selector) # cache result
- View#on
- View#off
- View#trigger
- View#attach(selector)
- View#detach()
- View#show()
- View#hide()
- View#remove()

and others.

## Horn.ListView

ListView has all Horn.View API

- ListView#size()
- ListView#size(num)
- ListView#addItem(item)
- ListView#get(num)
- ListView#toJSON()
- ListView#update(items)

Generate views as its size.

# Motivation

I used chaplin.js and Backbone.stickit for data bindings. In this style, I had to write many code even if I created simple view.
I need simple extendable template with js mappings as less-code as I can. I don't need ajax wrapper nor mapping because REST API is enough for me to make application.


## TODO

- Router and View instance mapping
- Document
- Test
- AMD style
- Register to bower
- TODO MVC
- Benchmark
