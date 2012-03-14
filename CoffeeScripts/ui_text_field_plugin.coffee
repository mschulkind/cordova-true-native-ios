TN.UI.TextField = class TextField extends TN.UI.View
  PLUGIN_NAME: 'textfield'

  constructor: (options) ->
    super options

    @align = options?.align ? 'left'
    @hint = options?.hint ? ''
    @text = options?.text

    @leftView = options?.leftView
    @rightView = options?.rightView

  registerSelfAndDescendants: ->
    super
    @leftView?.registerSelfAndDescendants()
    @rightView?.registerSelfAndDescendants()

  prepareSurroundingView: (view) ->
    if TN.UI.componentMap[@tnUIID]
      view.registerSelfAndDescendants()

  setProperties: (properties, onDone) ->
    for viewName in ['leftView', 'rightView']
      @prepareSurroundingView(properties[viewName]) if properties[viewName]?

    super

TextField.dismissKeyboard = ->
  Cordova.exec(null, null, @pluginID, 'dismissKeyboard', [])
