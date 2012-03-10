TN.UI.Window = class Window extends TN.UI.Component
  PLUGIN_NAME = 'window'

  constructor: (options) ->
    super options
    @pluginID = PLUGIN_ID

    @title = options?.title || ""

    # Explicit view constructors are only supported for windows, not for any
    # subclasses like tab controller.
    if @constructor == Window
      @private.constructView = options?.constructView
    else
      throw "constructView option not supported" if options?.constructView

    @addEventListener('destroyView', =>
      delete @private.view
    )

  open: (options) ->
    modal = options?.modal ? false

    @registerSelfAndDescendants()
    PhoneGap.exec(
      null, null, @pluginID, 'open',
      [
        window: this
        modal: modal
      ]
    )

  close: ->
    PhoneGap.exec(null, null, @pluginID, 'close', [windowID: @tnUIID])

  createView: ->
    @private.view = new TN.UI.View(backgroundColor: 'white')
    @private.view.registerSelfAndDescendants()
    @private.view

  constructView: (width, height) ->
    @private.view.width = width
    @private.view.height = height

    @private.constructView?(@private.view)
