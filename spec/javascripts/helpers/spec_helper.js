(function() {

  beforeEach(function() {
    var spy;
    if (!TN.UI.Component.prototype.noop.isSpy) {
      return spy = spyOn(TN.UI.Component.prototype, 'noop').andCallFake(function() {
        var _base;
        return typeof (_base = spy.mostRecentCall.args)[0] === "function" ? _base[0]() : void 0;
      });
    }
  });

}).call(this);
