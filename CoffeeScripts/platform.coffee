TN.isAndroid = ->
  DeviceInfo.platform.lastIndexOf('Android', 0) == 0

TN.isIphone = ->
  DeviceInfo.platform.lastIndexOf('iPhone', 0) == 0

TN.isSimulator = ->
  DeviceInfo.platform == 'iPhone Simulator'

TN.screenSize =
  width: 320
  height: 480
