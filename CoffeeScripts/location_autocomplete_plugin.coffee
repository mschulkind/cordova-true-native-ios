pluginID = 'cordovatruenative.locationautocomplete'

TN.LocationAutocomplete =
  completionsFor: (options) ->
    prefix = options?.prefix
    limit = options?.limit
    handler = options?.handler

    throw "prefix && handler required" unless prefix?

    execOptions =
      prefix: prefix
    execOptions.limit = limit if limit?
    Cordova.exec(handler, null, pluginID, 'completionsFor', [execOptions])
