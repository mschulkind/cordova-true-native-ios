TN.UI.Button = class Button extends TN.UI.View
  PLUGIN_NAME: 'button'

  defaultOptions =
    borderRadius: 5
    borderWidth: 1

  constructor: (options) ->
    options ||= {}
    TN.reverseMerge(defaultOptions, options)
    super options

    @title = options?.title

    @fontFamily = options?.fontFamily ? 'Helvetica Neue'
    @fontSize = options?.fontSize
    @fontWeight = options?.fontWeight
    @fontColor = options?.fontColor

    @highlightedBackgroundColor = options?.highlightedBackgroundColor

    @glowsOnTouch = options?.glowsOnTouch ? true
