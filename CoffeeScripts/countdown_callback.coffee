TN.CountdownCallback = class CountdownCallback
  constructor: (callback) ->
    @callback = callback
    @count = 0
    @started = false

  add: ->
    @count++
    =>
      @count--
      @callback() if (@started && @count == 0)

  start: ->
    @started = true
    @callback() if @count == 0
