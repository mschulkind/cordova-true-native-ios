TN.UI.TextField = class TextField extends TN.UI.View
  PLUGIN_NAME: 'textfield'

  constructor: (options) ->
    super options

    @align = options?.align ? 'left'
    @hint = options?.hint ? ''
    @text = options?.text

TextField.dismissKeyboard = ->
  Cordova.exec(null, null, @pluginID, 'dismissKeyboard', [])
