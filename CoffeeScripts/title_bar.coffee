TN.TitleBarButton = class TitleBarButton extends TN.Listenable
  constructor: (options) ->
    super

    @title = options?.title || ''
    @backgroundImagePath = options?.backgroundImagePath

TN.TitleBarView = class TitleBarView extends TN.UI.View
  BUTTON_BACKGROUND_COLOR = 'white'
  BUTTON_BORDER_WIDTH = 1
  BUTTON_WIDTH = 60
  BUTTON_HEIGHT = 28

  constructor: (options) ->
    super(_(width: 320, height: 44).extend(options))

    @private.leftButton = @createButton()
    @private.rightButton = @createButton()

    # Create the grid cell that handles the title bar view and add the
    # buttons.
    @private.gridCell = gridCell = new TN.GridCell(
      inheritViewSizeMode: 'both'
      view: this
      verticalAlign: 'middle'
      padding: 5
    )

    spacer = new TN.GridCell(
      growMode: 'horizontal'
    )

    gridCell.batchUpdates(=>
      gridCell.add(@private.leftButton)
      gridCell.add(spacer)
      gridCell.add(@private.rightButton)
    )

    # Array of [leftButton, rightButton] used as a stack.
    @private.buttonStack = []

  createButton: ->
    new TN.UI.Button(
      backgroundColor: BUTTON_BACKGROUND_COLOR
      borderWidth: BUTTON_BORDER_WIDTH
      width: BUTTON_WIDTH
      clickTargetWidth: BUTTON_WIDTH
      height: BUTTON_HEIGHT
      clickTargetHeight: BUTTON_HEIGHT
      fontSize: 12
      fontFamily: 'Helvetica Neue'
      fontColor: '#2D2D2D'
      fontWeight: 'bold'
      hidden: true
    )

  setButton: (button, data) ->
    if data?
      button.setProperty('title', data.title)

      if button.userData.clickListener?
        button.removeEventListener('click', button.userData.clickListener)
      button.userData.clickListener = button.addEventListener('click', (e) =>
        data.fireEvent('click', e)
      )

      if data.backgroundImagePath?
        # TODO(mschulkind): Fix this craziness once sizeToFitBackground is
        # ready.
        if button.backgroundImagePath != data.backgroundImagePath
          # Set the button size to 0x0 so it will grow to the exact size of the
          # image.
          button.setProperties(
            width: 0
            height: 0
          )
          button.setProperties(
            backgroundImagePath: data.backgroundImagePath
            borderWidth: 0
          )
      else
        button.setProperty('backgroundImagePath', '')
        button.setProperty('backgroundColor', 'white')
        button.setProperties(
          backgroundColor: BUTTON_BACKGROUND_COLOR
          borderWidth: BUTTON_BORDER_WIDTH
          width: BUTTON_WIDTH
          height: BUTTON_HEIGHT
        )

      # It's possible that the gridcell has not yet been created yet, so we
      # conditionally call layout here.
      @private.gridCell?.layout()

    button.setProperty('hidden', !data?)

  setLeftButton: (data) ->
    @private.leftButtonData = data
    @setButton(@private.leftButton, data)

  setRightButton: (data) ->
    @private.rightButtonData = data
    @setButton(@private.rightButton, data)

  setButtons: (left, right) ->
    @private.gridCell.batchUpdates(=>
      @setLeftButton(left)
      @setRightButton(right)
    )

  pushButtons: (left, right) ->
    @private.buttonStack.push([
      @private.leftButtonData || null,
      @private.rightButtonData || null
    ])
    @setButtons(left, right)

  popButtons: ->
    throw "stack empty" if @private.buttonStack.length == 0
    [left, right] = @private.buttonStack.pop()
    @setButtons(left, right)

  addButtonsForView: (options) ->
    view = options?.view
    throw "view required" unless view

    leftButton = options?.leftButton ? null
    rightButton = options?.rightButton ? null
    @pushButtons(leftButton, rightButton)

    view.addEventListener('destroy', =>
      @popButtons()
    )
