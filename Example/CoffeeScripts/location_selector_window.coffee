mruListKey = 'cityMRUList'
getMRUList = ->
  mruListJSON = window.localStorage.getItem(mruListKey)
  if mruListJSON?
    JSON.parse(mruListJSON)
  else
    []

updateMRUList = (city) ->
  mruList = getMRUList()

  # Remove the city if it's already in the list.
  mruList = _(mruList).without(
    _(mruList).find((c) ->
      c.name == city.name
    )
  )

  # Add the city to the front of the list.
  mruList.unshift(city)

  # Shrink the list to at most 10 elements.
  mruList.splice(10)

  window.localStorage.setItem(mruListKey, JSON.stringify(mruList))

constructCompletionView = (view, win, handler) ->
  addClickHandler = (row) ->
    row.addEventListener('click', ->
      win.close()
      updateMRUList(row.userData.city)
      handler(row.userData.city)
    )

  # Table view with completions.
  tableView = new TN.UI.TableView(
    style: 'grouped'
    backgroundColor: 'groupTableViewBackground'
  )

  # Completion row template.
  tableView.addRowTemplate(
    constructCallback: (rowEntry, row) ->
      addClickHandler(row)

    reuseCallback: (rowEntry, row) ->
      row.setProperty('text', rowEntry.userData.city.name)
      row.userData.city = rowEntry.userData.city
  )

  tableView.addEventOnceListener('resize', ->
    tableView.setProperty('headerView',
      App.createSearchBoxHeaderView(
        hint: 'US City (e.g. Brooklyn, NY)'

        onChange: (e) ->
          updateCompletions(e.text)
      )
    )
  )
  TN.glueViews(view, tableView)

  # Handle updating the completion options on text field change.
  updateCompletions = (text) ->
    updateWithCities = (cities) ->
      entries = []
      for city in cities
        entries.push(
          userData:
            city: city
        )
      tableView.setProperty('entries', entries)

    if text
      TN.LocationAutocomplete.completionsFor(
        prefix: text
        limit: 15
        handler: (completions) ->
          updateWithCities(completions)
      )
    else
      updateWithCities(getMRUList())

  # Start the table view with no completions and debounce any further calls.
  updateCompletions('')
  updateCompletions = _(updateCompletions).debounce(300)

App.getLocationSelection = (handler) ->
  navController = new TN.UI.NavigationController(
    titleView: new TN.TitleBarView
  )

  win = new TN.UI.Window(
    title: 'Choose Location'
    constructView: (view) ->
      cancelButton = new TN.TitleBarButton(title: 'Cancel')
      cancelButton.addEventListener('click', ->
        navController.close()
      )
      navController.titleView.addButtonsForView(
        view: view
        rightButton: cancelButton
      )

      TN.spinnerizeView(view, (removeSpinner) ->
        # Retrieve 0 completions for "" while spinning to ensure that the
        # location data is cached.
        TN.LocationAutocomplete.completionsFor(
          prefix: ""
          limit: 0
          handler:  ->
            removeSpinner()
            constructCompletionView(view, navController, handler)
        )
      )
  )

  navController.push(win)
  navController.open(modal: true)
