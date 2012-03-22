TN.UI.ScrollView = class ScrollView extends TN.UI.View
  PLUGIN_NAME: 'scrollview'

  constructor: (options) ->
    super

    @contentView = options?.contentView || new TN.UI.View
    @contentHeight = @contentView.height
    @contentWidth = @contentView.width
    @add(@contentView)

    @contentView.addEventListener('resize', (e) =>
      @setProperties(
        contentHeight: e.height
        contentWidth: e.width
      )
    )

  registerSelfAndDescendants: ->
    super
    @contentView.registerSelfAndDescendants()
