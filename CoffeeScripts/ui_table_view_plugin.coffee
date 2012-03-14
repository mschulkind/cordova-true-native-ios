TN.UI.TableView = class TableView extends TN.UI.View
  PLUGIN_NAME: 'tableview'

  constructor: (options) ->
    super

    @entries =
      if options?.entries?
        @preprocessEntries(options.entries)
      else
        []

    @rowHeight = options?.rowHeight || 44

    @headerView = options?.headerView
    @footerView = options?.footerView
    @addEventListener('resize', (e) =>
      @headerView?.setProperty('width', e.width)
      @footerView?.setProperty('width', e.width)
    )
    @addEventListener('show', =>
      @headerView?.fireEvent('show')
      @footerView?.fireEvent('show')
    )
    @addEventListener('hide', =>
      @headerView?.fireEvent('hide')
      @footerView?.fireEvent('hide')
    )

    @style = options?.style ? 'plain'
    @scrollEnabled = options?.scrollEnabled ? true

    @editing = options?.editing ? false

    @rowTemplateMap = {}

    if options?.refreshCallback?
      @enablePullToRefresh(options.refreshCallback)
      @pullToRefresh = true

    # Set scrollsToTop to false on hide since for whatever reason, iOS doesn't
    # do this automatically.
    @addEventListener('hide', =>
      @setProperty('scrollsToTop', false)
    )
    @addEventListener('show', =>
      @setProperty('scrollsToTop', true)
    )

  registerSelfAndDescendants: ->
    super
    @headerView?.registerSelfAndDescendants()
    @footerView?.registerSelfAndDescendants()

  addRowTemplate: (options) ->
    templateName = options?.templateName ? 'default'
    constructCallback = options?.constructCallback
    reuseCallback = options?.reuseCallback

    unless constructCallback || reuseCallback
      throw "constructCallback || reuseCallback required"

    @rowTemplateMap[templateName] =
      constructCallback: constructCallback
      reuseCallback: reuseCallback

  createRow: ->
    row = new TN.UI.TableViewRow
    row.registerSelfAndDescendants()

    row

  callRowCallback: (sectionIndex, rowIndex, rowID, callbackName) ->
    if sectionIndex == -1
      rowEntry = @entries[rowIndex]
    else
      sectionEntry = @entries[sectionIndex]
      # TODO(mschulkind): Reenable this check once the craziness is fixed.
      return unless sectionEntry
      #throw "section entry not found" unless sectionEntry
      rowEntry = sectionEntry.entries[rowIndex]
    # TODO(mschulkind): Remove this return once the craziness is fixed.
    return unless rowEntry
    throw "row entry not found" unless rowEntry

    row = TN.UI.componentMap[rowID]
    throw "row not found" unless row

    templateName = rowEntry.templateName ? 'default'
    rowTemplate = @rowTemplateMap[templateName]
    throw "missing template '#{templateName}'" unless rowTemplate

    callback = rowTemplate["#{callbackName}Callback"]
    callback?(rowEntry, row)

  constructRow: (sectionIndex, rowIndex, rowID) ->
    @callRowCallback(sectionIndex, rowIndex, rowID, 'construct')

  reuseRow: (sectionIndex, rowIndex, rowID) ->
    @callRowCallback(sectionIndex, rowIndex, rowID, 'reuse')

  enablePullToRefresh: (refreshCallback) ->
    @refreshListener = @addEventListener('refresh', =>
      inRefreshCallback = true
      refreshCallback((success) =>
        notifyNative = =>
          success ?= true
          Cordova.exec(
            null, null, @pluginID, 'refreshDone',
            [
              tableViewID: @tnUIID
              success: success
            ]
          )

        # Avoid calling refreshDone directly inside of the refresh listener.
        # Bad things happen otherwise.
        if inRefreshCallback
          _(notifyNative).defer()
        else
          notifyNative()
      )
      inRefreshCallback = false
    )

  disablePullToRefresh: ->
    @removeEventListener('refresh', @refreshListener)

  preprocessEntries: (entries) ->
    newEntries = TN.clone entries

    functionizeUserData = (array) ->
      for entry in array
        entry.userData = TN.merge(entry.userData, ->) if entry.userData
        functionizeUserData(entry.entries) if entry.entries?

    functionizeUserData(newEntries)

    newEntries

  prepareSurroundingView: (view) ->
    if TN.UI.componentMap[@tnUIID]
      view.setProperty('width', @width)
      view.registerSelfAndDescendants()

  setProperties: (properties, onDone) ->
    if properties.entries?
      properties.entries = @preprocessEntries(properties.entries)

    @prepareSurroundingView(properties.headerView) if properties.headerView?
    @prepareSurroundingView(properties.footerView) if properties.footerView?

    # Pass a pullToRefresh bool to the native side instead of the refresh
    # callback.
    if properties.refreshCallback != undefined
      if properties.refreshCallback instanceof Function
        properties.pullToRefresh = true
        @enablePullToRefresh(properties.refreshCallback)
      else
        properties.pullToRefresh = false
        @disablePullToRefresh()

      delete properties.refreshCallback

    super

  refreshRow: (sectionIndex, rowIndex) ->
    Cordova.exec(
      null, null, @pluginID, 'refreshRow',
      [
        tableViewID: @tnUIID
        sectionIndex: sectionIndex
        rowIndex: rowIndex
      ]
    )
