App.createTwitterDemoWindow = ->
  new TN.UI.Window(
    title: 'Twitter'
    constructView: (view) ->
      query = ''

      tableView = new TN.UI.TableView(
        rowHeight: 86

        # Provide a fetcher so the table is pull-to-refreshable.
        refreshCallback: (onDone) ->
          updateResults(onDone)
      )

      updateResults = (onDone) ->
        if query
          TN.HTTP.fetch(
            url: 'http://search.twitter.com/search.json'
            params:
              q: query
              rpp: 100
              result_type: 'recent'

            successHandler: (response) ->
              results = JSON.parse(response.data).results
              entries = []

              for result in results
                entries.push(
                  userData:
                    image: result.profile_image_url
                    user: result.from_user
                    text: result.text
                )

              tableView.setProperty('entries', entries)

              onDone?()

            errorHandler: ->
              alert 'Error running search.'
              onDone?(false)
          )

      tableView.addRowTemplate(
        constructCallback: (rowEntry, row) ->
          gridCell = TN.cellForView(row,
            layoutMode: 'vertical'
          )

          nameCell = new TN.GridCell(
            growMode: 'horizontal'
            fixedHeight: 28
            view: new TN.UI.View(
              backgroundColor: 'black'
            )
          )
          gridCell.add(nameCell)
          row.userData.nameLabel = nameLabel = new TN.UI.Label(
            fontSize: 16
            fontWeight: 'bold'
            color: 'white'
            top: 10
            left: 5
            height: 18
          )
          nameCell.view.add(nameLabel)
          nameCell.view.addEventListener('resize', ->
            nameLabel.setProperty('width', nameCell.view.width)
          )

          imageAndTextCell = new TN.GridCell(
            growMode: 'horizontal'
            padding: 5
          )
          gridCell.add(imageAndTextCell)
          row.userData.imageView = imageView = new TN.UI.ImageView(
            width: 48
            height: 48
            backgroundColor: '#bbb'
          )
          imageAndTextCell.add(imageView)

          imageAndTextCell.add(new TN.UI.View(width: 5))

          row.userData.textLabel = textLabel = new TN.UI.Label(
            fontSize: 12
            maxNumberOfLines: 0
          )
          imageAndTextCell.add(new TN.GridCell(
            growMode: 'both'
            view: textLabel
          ))

        reuseCallback: (rowEntry, row) ->
          row.userData.imageView.setProperty(
            'imageURL', rowEntry.userData.image)
          row.userData.nameLabel.setProperty(
            'text', "@#{rowEntry.userData.user}")
          row.userData.textLabel.setProperty('text', rowEntry.userData.text)
      )

      # Wait until the tableView is resized by the glueing below. If we don't
      # wait, the headerView will not be wide enough to accomodate the search
      # box.
      tableView.addEventOnceListener('resize', ->
        tableView.setProperty('headerView',
          App.createSearchBoxHeaderView(
            hint: 'Search twitter here...'

            # Run the search when the done button on the keyboard is clicked.
            onDone: (e) ->
              query = e.text
              updateResults()
          )
        )
      )

      TN.glueViews(view, tableView)
  )
