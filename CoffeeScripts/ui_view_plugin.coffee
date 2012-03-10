TN.UI.View = class View extends TN.UI.Component
  PLUGIN_NAME: 'view'

  constructor: (options) ->
    super options

    throw "centerX && left" if options?.centerX? and options?.left?
    if options?.centerX?
      @centerX = options.centerX
    else
      @left = options?.left ? 0

    throw "centerY && top" if options?.centerY? and options?.top?
    if options?.centerY?
      @centerY = options.centerY
    else
      @top = options?.top ? 0

    @width = options?.width ? 0
    @height = options?.height ? 0
    @hidden = options?.hidden ? false
    @visible = false

    @backgroundColor = options?.backgroundColor
    @backgroundImagePath = options?.backgroundImagePath
    unless @backgroundColor || @backgroundImagePath
      @backgroundColor = 'clear'

    @borderRadius = options?.borderRadius ? 0
    @borderWidth = options?.borderWidth ? 0
    @borderColor = options?.borderColor ? 'black'

    @userInteractionEnabled = options?.userInteractionEnabled ? true

    @clickTargetScale = options?.clickTargetScale ? 1
    @clickTargetWidth = options?.clickTargetWidth
    @clickTargetHeight = options?.clickTargetHeight

    @children = []

    # Since this is added as the first event listener, it should have a chance
    # to update the components width/height before any event listeners added
    # downstream get added.
    @addEventListener('resize', (e) =>
      @width = e.width
      @height = e.height
    )

    @addEventListener('show', (e) =>
      @visible = true
      for child in @children when child.hidden == false
        child.fireEvent('show', e)
    )
    @addEventListener('hide', (e) =>
      @visible = false
      for child in @children when child.hidden == false
        child.fireEvent('hide', e)
    )

  add: (child) ->
    @children.push(child)

    if TN.UI.componentMap[@tnUIID]?
      child.registerSelfAndDescendants()

      onDone = =>
        child.fireEvent('show') if @visible && !child.hidden

      Cordova.exec(
        onDone, null, @pluginID, 'add',
        [
          parentID: @tnUIID
          child: child
        ]
      )

  remove: (child) ->
    childIndex = @children.indexOf(child)
    throw "child not found" unless childIndex != -1
    @children.splice(childIndex, 1)

    if TN.UI.componentMap[@tnUIID]?
      Cordova.exec(
        null, null, @pluginID, 'remove', [childID: child.tnUIID])

  bringChildToFront: (child) ->
    childIndex = @children.indexOf(child)
    throw "child not found" if childIndex == -1

    @children.push(@children.splice(childIndex, 1)[0])

    if TN.UI.componentMap[@tnUIID]?
      Cordova.exec(
        null, null, @pluginID, 'bringChildToFront',
        [
          parentID: @tnUIID
          childID: child.tnUIID
        ]
      )

  getProperties: (names, onDone) ->
    # In case sizeToFit was called previously, but not yet completed, and the
    # component has not yet created on the native side, we have to make sure to
    # wait for sizeToFit to finish before calling onDone when requesting either
    # width or height. All calls to native code are serialized, but
    # getProperties only calls out to native code if the component has been
    # previosuly created. To make sure a native call is made before the given
    # onDone is called, we chain in a noop from the native side.
    if ((names.indexOf('width') != -1 || names.indexOf('height') != -1) &&
        !TN.UI.componentMap[@tnUIID]?)
      super(names, => @noop(onDone))
    else
      super

  setProperties: (properties, onDone) ->
    previousHidden = @hidden
    previousHeight = @height
    previousWidth = @width
    super properties, =>
      if ((properties.width? && previousWidth != @width) ||
          (properties.height? && previousHeight != @height))
        @fireEvent('resize',
          height: @height
          width: @width
        )

      if properties.hidden?
        if properties.hidden != previousHidden
          switch properties.hidden
            when true then @fireEvent('hide')
            when false then @fireEvent('show')

      onDone?()

  registerSelfAndDescendants: ->
    super
    for child in @children
      child.registerSelfAndDescendants()

  getSizeThatFits: ->
    throw "not supported"

  sizeToFit: (onDone) ->
    if TN.UI.componentMap[@tnUIID]?
      Cordova.exec(
        onDone, null, @pluginID, 'sizeToFit', [viewID: @tnUIID])
    else
      @getSizeThatFits((size) =>
        # In case the view has been created on the native side between
        # sizeToFit being called and this callback being run, we pass the new
        # size values through setProperties instead of merging them in
        # directly.
        @setProperties(size, onDone)
      )
