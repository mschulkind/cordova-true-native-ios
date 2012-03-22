TN.acquireLocation = (options) ->
  localSuccessCallback = (position) ->
    TN.hideProgressHUD()
    options?.success?(position)

  localErrorCallback = ->
    alert("Error acquiring current location.")
    TN.hideProgressHUD()
    options?.failure?()

  TN.showProgressHUD('Acquiring Location...')
  navigator.geolocation.getCurrentPosition(
    localSuccessCallback, localErrorCallback)
