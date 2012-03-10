TN.showProgressHUD = (label) ->
  PhoneGap.exec(
    null, null, 'com.github.cordova-true-native.mbprogresshud', 'show', [{label: label}])

TN.hideProgressHUD = ->
  PhoneGap.exec(null, null, 'com.github.cordova-true-native.mbprogresshud', 'hide', [])
