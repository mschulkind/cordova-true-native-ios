window.navigator =
  geolocation: {}


class Event
  initEvent: (type) ->
    throw "type required" unless type?
    @type = type

document.createEvent = (type) ->
  throw "type must be 'Events'" unless type == 'Events'
  new Event

class Listenable
  constructor: ->
    @listeners = {}
  addEventListener: (type, listener) ->
    @listeners[type] ||= []
    @listeners[type] += listener

  removeEventListener: (type, listener) ->
    callbackIndex = @eventListeners[eventName]?.indexOf?(eventCallback)
    @listeners[eventName].splice(callbackIndex, 1)

  dispatchEvent: (type) ->
    if @listeners[type]
      callback(type) for callback in @listeners[type]

documentEventHandler = new Listenable

document.addEventListener = (type, listener) ->
  documentEventHandler.addEventListener(type, listener)

document.removeEventListener = (type, listener) ->
  documentEventHandler.removeEventListener(type, listener)

document.dispatchEvent = (event) ->
  documentEventHandler.dispatchEvent(event.type)

window.shouldRotateToOrientation = ->
  ''
