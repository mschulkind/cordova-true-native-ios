pluginID = 'cordovatruenative.file'

TN.File =
  read: (filename, handler) ->
    PhoneGap.exec(handler, null, pluginID, 'read', [filename: filename])
