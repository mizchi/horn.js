// Generated by CoffeeScript 1.6.3
(function() {
  var Status, StatusList, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Horn.addDirective("data-click-with-trigger", function(view) {
    var $el,
      _this = this;
    $el = view.$("[data-click-with-trigger]");
    return $el.on('click', function(e) {
      var eventName;
      eventName = $(e.target).data('click-with-trigger');
      return view.trigger(eventName);
    });
  });

  Horn.registerTemplate("<div\n  data-template-name=\"my-status\"\n  data-attrs=\"name, money, showAddMoney\">\n\n  <span data-text=\"name\">NO NAME</span>\n  <span data-text=\"money\">0</span>\n  <button data-click-with-trigger=\"update\">update</button>\n  <button data-click=\"dispose\">dispose</button>\n  <button data-click=\"toggleShowAddMoney\">toggle show add money</button>\n  <button data-visible=\"showAddMoney\" data-click=\"addMoney\">addMoney</button>\n</div>");

  Status = (function(_super) {
    __extends(Status, _super);

    function Status() {
      _ref = Status.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Status.prototype.templateName = 'my-status';

    Status.prototype.addMoney = function() {
      return this.money += 10;
    };

    Status.prototype.toggleShowAddMoney = function() {
      return this.showAddMoney = !this.showAddMoney;
    };

    return Status;

  })(Horn.View);

  StatusList = (function(_super) {
    __extends(StatusList, _super);

    function StatusList() {
      _ref1 = StatusList.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    StatusList.prototype.itemView = Status;

    StatusList.prototype.templateName = 'my-status-list';

    return StatusList;

  })(Horn.ListView);

  $(function() {
    var list, status;
    status = new Status;
    status.name = 'foo';
    status.money = 0;
    status.attach('body');
    status.on('update', function() {
      return console.log('updated');
    });
    list = new StatusList;
    list.update([
      {
        name: 1
      }, {
        name: 2
      }, {
        name: 3
      }
    ]);
    list.addItem({
      name: 4
    });
    list.attach('body');
    return window.list = list;
  });

}).call(this);
