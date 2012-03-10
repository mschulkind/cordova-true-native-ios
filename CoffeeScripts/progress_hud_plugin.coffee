TN.showProgressHUD = (label) ->
  Cordova.exec(
    null, null, 'CordovaTrueNative.mbprogresshud', 'show', [{label: label}])

TN.hideProgressHUD = ->
  Cordova.exec(null, null, 'CordovaTrueNative.mbprogresshud', 'hide', [])
