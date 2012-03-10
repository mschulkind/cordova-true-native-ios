TN.UI.ActionSheet = class ActionSheet extends TN.UI.View
  PLUGIN_NAME: 'actionsheet'

  constructor: (options) ->
    super

    @title = options?.title ? ''

    @shown = false
    @buttons = []

    @addEventListener('actionSheetClick', (e) =>
      button = @buttons[e.index]
      raise "button not found" unless button?

      button?.action()
    )

  addButton: (options) ->
    raise "can't add buttons after showing" if @shown

    @buttons.push(
      title: options?.title || ''
      type: options?.type
      action: options?.action
    )

  show: ->
    @shown = true
    @registerSelfAndDescendants()
    Cordova.exec(null, null, @pluginID, 'show', [actionSheet: this])
