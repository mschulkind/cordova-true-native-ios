window.onBodyLoad = ->
  document.addEventListener("deviceready", onDeviceReady, false)

window.onDeviceReady = ->
  Cordova.exec(null, null, 'cordovatruenative.component', 'loadJavascript', [])

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

document.addEventListener('deviceready', onDeviceReady, false)
