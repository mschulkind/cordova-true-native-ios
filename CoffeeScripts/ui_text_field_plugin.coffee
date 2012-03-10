PLUGIN_NAME = 'textfield'
TN.UI.TextField = class TextField extends TN.UI.View
  constructor: (options) ->
    super options
    @pluginID = PLUGIN_ID

    @align = options?.align ? 'left'
    @hint = options?.hint ? ''
    @text = options?.text

TextField.dismissKeyboard = ->
  PhoneGap.exec(null, null, PLUGIN_ID, 'dismissKeyboard', [])
