window.onBodyLoad = ->
  document.addEventListener("deviceready", onDeviceReady, false)

window.onDeviceReady = ->
  Cordova.exec(
    onTNReady, null, 'cordovatruenative.component', 'loadJavascript', [])

document.addEventListener('deviceready', onDeviceReady, false)

onTNReady = ->
  new TN.UI.Window(
    constructView: (view) ->
      view.setProperty('backgroundColor', 'black')

      label = new TN.UI.Label(
        text: "Hello, World!"
        color: 'white'
        top: 5
        left: 10
      )
      label.sizeToFit()
      view.add(label)
  ).open()

