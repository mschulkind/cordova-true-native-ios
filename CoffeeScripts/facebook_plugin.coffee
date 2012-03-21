TN.Facebook = class Facebook
  PLUGIN_ID = 'cordovatruenative.facebook'

  constructor: (options) ->
    Cordova.exec(null, null , PLUGIN_ID, 'setup', [appID: options?.appID])

  login: (permissions, onSuccess, onFail) ->
    Cordava.exec(
      onSuccess, onFail, PLUGIN_ID, 'login',
      [{permissions: permissions}])
