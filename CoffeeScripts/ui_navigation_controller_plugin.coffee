TN.UI.NavigationController = class NavigationController extends TN.UI.Window
  PLUGIN_NAME: 'navigationcontroller'

  constructor: (options) ->
    super
    @pluginID = PLUGIN_ID

    @titleView = options?.titleView
    @title = options?.title || ""

    @windowStack = []

  push: (window) ->
    @windowStack.push(window)

    if TN.UI.componentMap[@tnUIID]?
      window.registerSelfAndDescendants()
      Cordova.exec(
        null, null, @pluginID, 'push',
        [
          parentID: @tnUIID
          child: window
        ]
      )

  pop: ->
    @windowStack.pop()

    if TN.UI.componentMap[@tnUIID]?
      Cordova.exec(null, null, @pluginID, 'pop', [parentID: @tnUIID])

  willPopToRootWindow: ->
    @windowStack.splice(1)

  registerSelfAndDescendants: ->
    super
    window.registerSelfAndDescendants() for window in @windowStack
    @titleView?.registerSelfAndDescendants()
