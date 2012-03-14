App.createTwitterDemoWindow = ->
  new TN.UI.Window(
    title: 'Twitter'
    constructView: (view) ->
      textField = new TN.UI.TextField(
        hint: 'Search twitter here...'
        borderWidth: 1
        borderColor: 'black'
        borderRadius: 15
        backgroundColor: 'white'
        leftView: new TN.UI.View(width: 10)
      )
      headerCell = new TN.GridCell(
        padding: 10
        inheritViewSizeMode: 'width'
        fixedHeight: 50
        view: new TN.UI.View(
          backgroundColor: 'gray'
        )
      )

      tableView = new TN.UI.TableView(
        headerView: headerCell.view
        rowHeight: 58

        # Provide a fetcher so the table is pull-to-refreshable.
        refreshCallback: (onDone) ->
          updateResults(onDone)
      )

      updateResults = (onDone) ->
        textField.getProperty('text', ->
          if textField.text
            TN.HTTP.fetch(
              url: 'http://search.twitter.com/search.json'
              params:
                q: textField.text
                rpp: 100
                result_type: 'recent'

              successHandler: (response) ->
                results = JSON.parse(response.data).results
                entries = []

                for result in results
                  entries.push(
                    userData:
                      image: result.profile_image_url
                      text: result.text
                  )

                tableView.setProperty('entries', entries)

                onDone?()

              errorHandler: ->
                alert 'Error running search.'
                onDone?(false)
            )
          else
            onDone?(false)
        )

      tableView.addRowTemplate(
        constructCallback: (rowEntry, row) ->
          gridCell = TN.cellForView(row,
            padding: 5
          )

          row.userData.imageView = imageView = new TN.UI.ImageView(
            width: 48
            height: 48
            backgroundColor: '#bbb'
          )
          gridCell.add(imageView)

          gridCell.add(new TN.UI.View(width: 5))

          row.userData.label = label = new TN.UI.Label(
            fontSize: 12
            maxNumberOfLines: 0
          )
          gridCell.add(new TN.GridCell(
            growMode: 'both'
            view: label
          ))

        reuseCallback: (rowEntry, row) ->
          row.userData.imageView.setProperty(
            'imageURL', rowEntry.userData.image)
          row.userData.label.setProperty('text', rowEntry.userData.text)
      )

      # Wait until the headerCell's view is resized to the tableView's new
      # width due to the glueing below. If we don't wait, the headerCell will
      # not be wide enough to accomodate the text field.
      headerCell.view.addEventOnceListener('resize', ->
        headerCell.add(new TN.GridCell(
          growMode: 'both'
          view: textField
        ))
      )

      TN.glueViews(view, tableView)

      # Run the search when the done button on the keyboard is clicked.
      textField.addEventListener('done', -> updateResults())
  )
