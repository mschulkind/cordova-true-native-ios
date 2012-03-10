TN.UI.Label = class Label extends TN.UI.View
  PLUGIN_NAME = 'label'

  defaultOptions =
    fontFamily: 'Helvetica Neue'
    color: '#969696'

  constructor: (options) ->
    options ||= {}
    TN.reverseMerge(defaultOptions, options)
    super options
    @pluginID = PLUGIN_ID

    @align = options?.align || 'left'
    @color = options?.color
    @text = options?.text || ''
    @fontFamily = options?.fontFamily ? 'Helvetica Neue'
    @fontSize = options?.fontSize
    @fontWeight = options?.fontWeight
    @maxNumberOfLines = options?.maxNumberOfLines ? 1

  getSizeThatFits: (callback) ->
    PhoneGap.exec(
      callback, null, @pluginID, 'getTextSize',
      [
        text: @text
        fontFamily: @fontFamily
        fontSize: @fontSize
        fontWeight: @fontWeight
        maxNumberOfLines: @maxNumberOfLines
        width: @width
      ]
    )
