TN.UI.MapView = class MapView extends TN.UI.View
  PLUGIN_NAME: 'mapview'

  constructor: (options) ->
    super

    @center = options?.center
    @span = options?.span
    @span ?=
      latitude: 0.003
      longitude: 0.003

    @scrollEnabled = options?.scrollEnabled ? true
    @zoomEnabled = options?.zoomEnabled ? true

    @pins = []

  addPin: (options) ->
    unless options?.longitude && options?.latitude
      throw "longitude && latitude required"

    @pins.push(options)

    if TN.UI.componentMap[@tnUIID]
      Cordova.exec(null, null, @pluginID, 'addPin',
        [
          mapViewID: @tnUIID
          pin: pin
        ]
      )
