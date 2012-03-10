TN.UI.TabController = class TabController extends TN.UI.Window
  PLUGIN_NAME: 'tabcontroller'

  constructor: (options) ->
    super options

    @tabs = []

  addTab: (tab) ->
    @tabs.push(tab)

  registerSelfAndDescendants: ->
    super
    for tab in @tabs
      tab.registerSelfAndDescendants()

  makeActive: (tabID) ->
    @currentTab?.fireEvent('deactivate')
    tab = TN.UI.componentMap[tabID]
    throw "tab not found" unless tab
    @currentTab = tab
    @currentTab.fireEvent('activate')

  switchTo: (tab) ->
    tabIndex = @tabs.indexOf(tab)
    throw "tab not found" if tabIndex == -1
    @setProperty('activeIndex', tabIndex)

  open: (options) ->
    throw "at least one tab required" if @tabs.length == 0
    super
    @makeActive(@tabs[0].tnUIID)
