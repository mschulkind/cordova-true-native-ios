TN.UI.Tab = class Tab extends TN.UI.NavigationController
  PLUGIN_NAME = 'tab'

  constructor: (options) ->
    super options
    @pluginID = PLUGIN_ID

    @title = options?.title || ""
    @tabBarImagePath = options?.tabBarImagePath
