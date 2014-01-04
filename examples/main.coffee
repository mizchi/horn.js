# Define custom directive
Horn.addDirective "data-click-with-trigger", (view) ->
  $el = view.$("[data-click-with-trigger]")
  $el.on 'click', (e) =>
    eventName = $(e.target).data('click-with-trigger')
    view.trigger eventName

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

class Status extends Horn.View
  templateName: 'my-status'
  addMoney: ->
    @money += 10

  toggleShowAddMoney: ->
    @showAddMoney = !@showAddMoney

class StatusList extends Horn.ListView
  itemView: Status
  templateName: 'my-status-list'

$ ->
  # View
  status = new Status
  status.name = 'foo'
  status.money = 0

  status.attach 'body'
  status.on 'update', -> console.log 'updated'

  # ListView
  list = new StatusList
  list.update [{name: 1},{name: 2},{name: 3}]
  list.addItem {name: 4}
  list.attach 'body'
  window.list = list

