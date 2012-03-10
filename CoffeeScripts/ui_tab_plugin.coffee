TN.UI.Tab = class Tab extends TN.UI.NavigationController
  PLUGIN_NAME: 'tab'

  constructor: (options) ->
    super options

    @title = options?.title || ""
    @tabBarImagePath = options?.tabBarImagePath
