pluginID = 'cordovatruenative.file'

TN.File =
  read: (filename, handler) ->
    Cordova.exec(handler, null, pluginID, 'read', [filename: filename])
