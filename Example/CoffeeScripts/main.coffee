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

      # Adds a row object to the entries array. Each object in the entries
      # array corresponds to one row of the table view.
      addExample = (name, window) ->
        entries.push(
          templateName: templateName
          userData:
            exampleName: name
            window: window
        )

      addExample('Action Sheet', App.createActionSheetDemoWindow())

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

      # Each row object specifies a template name. All rows here use the same
      # template name. This tells the table view about the template.
      tableView.addRowTemplate(templateName, constructRow, reuseRow)

      # Add the table view to the window's view and stretch it to fill the
      # window.
      TN.glueViews(view, tableView)
  ))
  navController.open()

  navController.push(new App.createActionSheetDemoWindow())
