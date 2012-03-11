TN.GridCell = class GridCell extends TN.Listenable
  constructor: (options) ->
    super

    @inheritViewSizeMode = options?.inheritViewSizeMode || 'none'
    unless @inheritViewSizeMode in ['none', 'width', 'height', 'both']
      throw 'Unknown inheritViewSizeMode'

    @fixedHeight = options?.fixedHeight
    @fixedWidth = options?.fixedWidth

    @view = options?.view || new TN.UI.View
    @view.width = @fixedWidth if @fixedWidth?
    @view.height = @fixedHeight if @fixedHeight?

    for dimension in ['width', 'height']
      if @isDimensionFixed(dimension) && @inheritsViewDimension(dimension)
        throw "inherited size and fixed size are mutually exclusive for a" +
              "given dimension."

    @fixedHeight = @view.height if @inheritsViewDimension('height')
    @fixedWidth = @view.width if @inheritsViewDimension('width')

    @growMode = options?.growMode || "none"
    unless @growMode in ["none", "vertical", "horizontal", "both"]
      throw "Unknown growMode"

    if @growsInDimension('height') && @isDimensionFixed('height')
      throw "vertical growMode and fixedHeight are mutually exclusive."
    if @growsInDimension('width') && @isDimensionFixed('width')
      throw "horizontal growMode and fixedWidth are mutually exclusive."

    @layoutMode = options?.layoutMode || "horizontal"
    unless @layoutMode in  ["vertical", "horizontal"]
      throw "Unknown layoutMode"

    @padding = options?.padding || 0
    @spacing = options?.spacing || 0

    @verticalAlign = options?.verticalAlign || 'top'
    unless @verticalAlign in ['top', 'middle']
      throw "Unknown verticalAlign"

    @parent = null
    @children = []

    @addEventListener('layout', =>
      for child in @children
        child.fireEvent('layout')
    )

  add: (viewOrCell) ->
    if viewOrCell instanceof GridCell
      cell = viewOrCell
    else if viewOrCell instanceof TN.UI.Component
      cell = new GridCell(
        view: viewOrCell
        inheritViewSizeMode: 'both'
      )
    else
      throw "not view or cell"

    throw "cell being added has already been added elsewhere" if cell.parent
    cell.parent = this
    @children.push(cell)
    @view.add(cell.view)

    # This add could have changed the cell's size which means its parents may
    # need to adjust, so call layout on the root parent instead of just on this
    # cell.
    @callOnRootParent('layoutOnAdd')

  fixedKeyForDimension: (dimension) ->
    key = {width: 'fixedWidth', height: 'fixedHeight'}[dimension]
    throw "Invalid dimension '#{dimension}'" unless key
    key

  isDimensionFixed: (dimension) ->
    @[@fixedKeyForDimension(dimension)]?

  inheritsViewDimension: (dimension) ->
    ['both', dimension].indexOf(@inheritViewSizeMode) != -1

  growsInDimension: (dimension) ->
    dimensionMap =
      width: 'horizontal'
      height: 'vertical'

    ['both', dimensionMap[dimension]].indexOf(@growMode) != -1

  maxNonGrowingChildSizeInDimension: (dimension) ->
    maxSize = 0
    for child in @children when !child.growsInDimension(dimension)
      maxSize = Math.max(maxSize, child.view[dimension])
    maxSize

  numChildrenGrowInDimension: (dimension) ->
    count = 0
    for child in @children
      count++ if child.growsInDimension(dimension)
    count

  updateViewDimension: (dimension, perfectFitSize) ->
    # Update the view size if not fixed.
    unless @isDimensionFixed(dimension)
      @view.setProperty(dimension, perfectFitSize)

    # Check to make sure everything still fits.
    if perfectFitSize > @view[dimension]
      throw "Cell #{dimension} too small to fit children. " +
            "#{perfectFitSize} > #{@view[dimension]}."

  layoutLayoutDimension: ->
    switch @layoutMode
      when 'vertical'
        sizeKey = 'height'
        positionKey = 'top'
      when 'horizontal'
        sizeKey = 'width'
        positionKey = 'left'
      else throw 'Invalid layoutMode'
    
    if @inheritsViewDimension(sizeKey)
      this[@fixedKeyForDimension(sizeKey)] = @view[sizeKey]
    
    # Find the total size of all children in the layout dimension that do not
    # grow along the layout dimension.
    totalNonGrowLayoutSize = 0
    for child in @children when !child.growsInDimension(sizeKey)
      # Let the child lay itself out first in case it changes size.
      child.layoutDimension(sizeKey)
      totalNonGrowLayoutSize += child.view[sizeKey]

    # Calculate the size of a child that grows in the layout dimension.
    numLayoutGrow = @numChildrenGrowInDimension(sizeKey)
    totalGrowLayoutSize =
      (@view[sizeKey] - 2*@padding -
       @spacing*(@children.length - 1) - totalNonGrowLayoutSize)
    growLayoutSize =
      Math.max(0, totalGrowLayoutSize / numLayoutGrow)
    # Round down the grow layout size.
    growLayoutSize = Math.round(growLayoutSize - 0.5)
    
    # Make sure if there are children that grow along the layout dimension,
    # that the parent cell has a fixed-size in the layout dimension.
    unless numLayoutGrow == 0 || @isDimensionFixed(sizeKey)
      throw "If a child is set to grow along the layout dimension," +
            " the parent must have a fixed size or grow in that dimension."
   
    # Grow and layout all of the growing children.
    growLayoutSizeLeft = totalGrowLayoutSize
    for child in @children when child.growsInDimension(sizeKey)
      # If the amount of grow size left is less than twice the grow layout
      # size, then this must be the last growing child. Set the last growing
      # child to be the size of the entire size left to account for any
      # rounding errors.
      if growLayoutSizeLeft < 2*growLayoutSize
        child.view.setProperty(sizeKey, growLayoutSizeLeft)
      else
        child.view.setProperty(sizeKey, growLayoutSize)

      growLayoutSizeLeft -= growLayoutSize

      child[@fixedKeyForDimension(sizeKey)] = child.view[sizeKey]

      child.layoutDimension(sizeKey)

    # Position all of the children.
    nextPosition = @padding
    for child in @children
      # Position the child.
      child.view.setProperty(positionKey, nextPosition)

      # Calculate the position of the next child.
      nextPosition += child.view[sizeKey]
      nextPosition += @spacing
    
    # Get rid of the extra @spacing left over from the trailing add in the
    # above loop.
    nextPosition -= @spacing
    
    @updateViewDimension(sizeKey, nextPosition + @padding)

  layoutOtherDimension: ->
    switch @layoutMode
      when 'vertical'
        throw "align mode not supported" unless @verticalAlign == 'top'
        align = 'beginning'

        sizeKey = 'width'
        positionKey = 'left'
      when 'horizontal'
        switch @verticalAlign
          when 'top' then align = 'beginning'
          when 'middle' then align = 'middle'
          else throw "Invalid verticalAlign"

        sizeKey = 'height'
        positionKey = 'top'
      else throw 'Invalid layoutMode'

    if @inheritsViewDimension(sizeKey)
      this[@fixedKeyForDimension(sizeKey)] = @view[sizeKey]

    # Layout all the non-growing children.
    for child in @children when !child.growsInDimension(sizeKey)
      child.layoutDimension(sizeKey)
    
    # Grow and layout all of the growing children.
    maxChildSize = @maxNonGrowingChildSizeInDimension(sizeKey)
    contentSize = 0
    if @isDimensionFixed(sizeKey)
      contentSize = @view[sizeKey] - 2*@padding
    else
      contentSize = maxChildSize
    for child in @children when child.growsInDimension(sizeKey)
      child.view.setProperty(sizeKey, contentSize)
      child[@fixedKeyForDimension(sizeKey)] = contentSize
      child.layoutDimension(sizeKey)

    # Position all of the children.
    for child in @children
      # Position the child (without considering aligment).
      child.view.setProperty(positionKey, @padding)

      # Apply the alignment, which only makes sense if the cell is not set to
      # grow in the other dimension.
      if !child.growsInDimension(sizeKey) && align == 'middle'
        child.view.setProperty(
          positionKey,
          child.view[positionKey] + contentSize/2 - child.view[sizeKey]/2)

    unless @growsInDimension(sizeKey)
      @updateViewDimension(sizeKey, maxChildSize + 2*@padding)

  layoutDimension: (dimension) ->
    throw "Invalid dimension" if ['width', 'height'].indexOf(dimension) == -1
    switch @layoutMode
      when "vertical"
        switch dimension
          when 'height' then @layoutLayoutDimension()
          when 'width' then @layoutOtherDimension()
      when "horizontal"
        switch dimension
          when 'height' then @layoutOtherDimension()
          when 'width' then @layoutLayoutDimension()
      else throw "Invalid layoutMode"

  callForSelfAndAllDescendants: (functionName, countdownCallback) ->
    this[functionName]?(countdownCallback)
    for child in @children
      child.callForSelfAndAllDescendants(functionName, countdownCallback)

  getUpdatedSizes: (countdownCallback) ->
    # If a cell does not inherit its view's dimension, then there's no sense
    # requesting the new dimension.
    for cell in @children.concat([this])
      inheritedDimensions = []
      for dimension in ['width', 'height']
        if cell.inheritsViewDimension(dimension)
          inheritedDimensions.push(dimension)

      if inheritedDimensions.length > 0
        cell.view.getProperties(inheritedDimensions, countdownCallback.add())

  layout: ->
    if @parent
      @callOnRootParent('layout')
    else
      countdownCallback = new TN.CountdownCallback(=> @layoutPart2())
      @callForSelfAndAllDescendants('getUpdatedSizes', countdownCallback)
      countdownCallback.start()

  layoutPart2: ->
    @layoutLayoutDimension()
    @layoutOtherDimension()
    
    @fireEvent('layout')

  layoutOnAdd: ->
    @layout() unless @disableLayoutOnAdd

  callOnRootParent: (methodName, arg) ->
    rootParent = this
    rootParent = rootParent.parent while rootParent.parent
    rootParent[methodName](arg)

  # Allows for batching updates in the given callback by temporarily disabling
  # layout() calls on each add() and instead only calling layout once at the
  # end.
  batchUpdates: (callback) ->
    if @parent
      @callOnRootParent('batchUpdates', callback)
    else
      unless @disableLayoutOnAdd
        @disableLayoutOnAdd = true
        callback()
        @disableLayoutOnAdd = false
        @layout()
      else
        # Don't do anything special if called nested.
        callback()

