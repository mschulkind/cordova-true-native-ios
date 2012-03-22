createWindowForPhoto = (photo) ->
  new TN.UI.Window(
    title: photo.user.username
    constructView: (view) ->
      scrollView = new TN.UI.ScrollView(
        contentView: new TN.UI.ImageView(
          imageURL: photo.images.standard_resolution.url
          width: 612
          height: 612
        )
      )
      TN.glueViews(view, scrollView)
  )

App.createInstagramDemoWindow = (parentNav) ->
  new TN.UI.Window(
    title: 'Instagram'
    constructView: (view) ->
      instructionsCell = new TN.GridCell(
        layoutMode: 'vertical'
        padding: 10
        fixedWidth: TN.screenSize.width
      )
      view.add(instructionsCell.view)

      displayResults = (location) ->
        view.remove(instructionsCell.view)

        TN.HTTP.fetch(
          url: 'https://api.instagram.com/v1/media/search'
          params:
            limit: 50
            lat: location.latlong[0]
            lng: location.latlong[1]
            distance: 5000
            count: 100
            client_id: 'e569e7276a8f4143bea78668837e39c5'

          successHandler: (response) ->
            photos = JSON.parse(response.data).data

            scrollView = new TN.UI.ScrollView
            TN.glueViews(view, scrollView)

            marginSize = 7
            spacingSize = 6
            photoSize = 150
            numRows = Math.ceil(photos.length / 2)
            scrollView.contentView.setProperties(
              width: 320
              height:
                (2*marginSize +
                 (numRows)*(photoSize + spacingSize) -
                 spacingSize)
            )

            nextTop = marginSize
            for firstPhoto, index in photos by 2
              secondPhoto = photos[index + 1]

              addPhoto = (photo, left) ->
                imageView = new TN.UI.ImageView(
                  imageURL: photo.images.thumbnail.url
                  backgroundColor: '#999'
                  top: nextTop
                  left: left
                  width: photoSize
                  height: photoSize
                )
                scrollView.contentView.add(imageView)

                imageView.addEventListener('click', ->
                  parentNav.push(createWindowForPhoto(photo))
                )

              addPhoto(firstPhoto, marginSize)
              if secondPhoto
                addPhoto(secondPhoto, marginSize + photoSize + spacingSize)

              nextTop += photoSize + spacingSize

          errorHandler: ->
            alert 'Error running search.'
        )

      instructionsCell.batchUpdates(->
        instructionsCell.add(TN.createGrowingLabelCell(
          text: 'You must choose a location first.'
          height: 20
        ))

        instructionsCell.add(new TN.UI.View(height: 10))
        chooseLocationButton = new TN.UI.Button(
          title: 'Choose Location'
          backgroundColor: 'black'
          borderColor: '#aaa'
          borderWidth: 2
        )
        chooseLocationButton.addEventListener('click', ->
          App.getLocationSelection((location) ->
            displayResults(location)
          )
        )
        instructionsCell.add(new TN.GridCell(
          view: chooseLocationButton
          growMode: 'horizontal'
          fixedHeight: 30
        ))
      )
  )
