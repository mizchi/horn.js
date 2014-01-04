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
  # window.a = new MyStatus
  # a.attach 'body'
  # a.on 'update', -> console.log 'updated'

  window.list = new StatusList
  list.attach 'body'
  list.update [{name: 1},{name: 2},{name: 3}]
