TN.Listenable = class Listenable
  constructor: ->
    # Declared as a function, yet used as an object to avoid
    # JSON.stringification.
    @eventListeners = ->

  addEventListener: (eventName, eventCallback) ->
    @eventListeners[eventName] ||= []
    @eventListeners[eventName].push(eventCallback)
    eventCallback

  addEventOnceListener: (eventName, eventCallback) ->
    onceListener = @addEventListener(eventName, (e) =>
      @removeEventListener(eventName, onceListener)
      eventCallback(e)
    )

  removeEventListener: (eventName, eventCallback) ->
    callbackIndex = @eventListeners[eventName]?.indexOf?(eventCallback)
    unless callbackIndex? && callbackIndex != -1
      throw "'#{eventName}' callback not found: #{eventCallback}"
    @eventListeners[eventName].splice(callbackIndex, 1)

  listensForEvent: (eventName) ->
    @eventListeners[eventName]? && @eventListeners[eventName].length != 0

  fireEvent: (eventName, eventData) ->
    if @eventListeners[eventName]
      # The clone here is to prevent problems if an event listener is removed
      # while iterating.
      for callback in _(@eventListeners[eventName]).clone()
        callback(eventData)

    # Don't return anything, especially since this is called directly from the
    # native side.
    null
