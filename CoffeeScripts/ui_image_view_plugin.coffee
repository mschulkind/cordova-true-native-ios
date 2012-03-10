TN.UI.ImageView = class ImageView extends TN.UI.View
  PLUGIN_NAME = 'imageview'

  constructor: (options) ->
    super options
    @pluginID = PLUGIN_ID

    @imagePath = options?.imagePath
    @imageURL = options?.imageURL
    throw "image path && url" if @imagePath? && @imageURL?

  getSizeThatFits: (callback) ->
    throw "unsupported for remote images" if @imageURL
    throw "imagePath required" unless @imagePath

    PhoneGap.exec(
      callback, null, @pluginID, 'getImageSize', [imagePath: @imagePath])

  setProperties: (properties, onDone) ->
    imagePath = @imagePath || properties.imagePath
    imageURL = @imageURL || properties.imageURL
    throw "image path && url" if imagePath? && imageURL?

    super
