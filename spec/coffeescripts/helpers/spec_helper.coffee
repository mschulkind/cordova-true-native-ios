beforeEach(->
  unless TN.UI.Component::noop.isSpy
    spy = spyOn(TN.UI.Component.prototype, 'noop')
      .andCallFake(-> spy.mostRecentCall.args[0]?())
)
