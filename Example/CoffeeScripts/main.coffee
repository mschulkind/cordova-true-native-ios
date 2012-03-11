window.onBodyLoad = ->
  document.addEventListener("deviceready", onDeviceReady, false)

window.onDeviceReady = ->
  Cordova.exec(
    onTNReady, null, 'cordovatruenative.component', 'loadJavascript', [])

document.addEventListener('deviceready', onDeviceReady, false)

onTNReady = ->
  navController = new TN.UI.NavigationController
  navController.push(new TN.UI.Window(
    title: "TrueNative"
    constructView: (view) ->
      templateName = 'exampleTemplate'
      entries = []
      addExample = (name, window) ->
        entries.push(
          templateName: templateName
          userData:
            exampleName: name
            window: window
        )

      addExample('Foo', new TN.UI.Window(title: 'test'))

      tableView = new TN.UI.TableView(entries: entries)

      constructRow = (rowEntry, row) ->
        row.setProperty('hasDetail', true)
        row.addEventListener('click', ->
          navController.push(row.userData.window)
        )

      reuseRow = (rowEntry, row) ->
        row.setProperty('text', rowEntry.userData.exampleName)
        
        # Save the window for the click handler.
        row.userData.window = rowEntry.userData.window

      tableView.addRowTemplate(templateName, constructRow, reuseRow)

      TN.glueViews(view, tableView)
  ))
  navController.open()
