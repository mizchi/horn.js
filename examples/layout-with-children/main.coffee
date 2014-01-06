# Define custom directive
Horn.addDirective "data-click-with-trigger", (view) ->
  $el = view.$("[data-click-with-trigger]")
  $el.on 'click', (e) =>
    eventName = $(e.target).data('click-with-trigger')
    view.trigger eventName

Horn.registerTemplate """
  <div
    data-template-name="layout"
    data-views="status, statusList"
    data-attrs="">
    <h1>layout</h1>
    <div data-view='status:status'/>
    <div data-list-view='status:statusList'/>
  </div>
"""

Horn.registerTemplate """
  <div
    data-template-name="status"
    data-attrs="name, money, showAddMoney">

    <span data-text="name">NO NAME</span>
    <span data-text="money">0</span>
    <button data-click-with-trigger="update">update</button>
    <button data-click="dispose">dispose</button>
    <button data-click="toggleShowAddMoney">toggle show add money</button>
    <button data-visible="showAddMoney" data-click="addMoney">addMoney</button>
  </div>
"""

class Layout extends Horn.View
  templateName: 'layout'
  viewClassMapping:
    status: -> Status

class Status extends Horn.View
  templateName: 'status'
  addMoney: ->
    @money += 10

  toggleShowAddMoney: ->
    @showAddMoney = !@showAddMoney

class StatusList extends Horn.ListView
  itemView: Status

$ ->
  layout = new Layout
  layout.attach 'body'
  layout.status.name = 'foo'
  layout.status.money = 0
  layout.statusList.update [{}, {}, {}]
