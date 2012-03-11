App.createActionSheetDemoWindow = ->
  new TN.UI.Window(
    title: 'Action Sheet'

    constructView: (view) ->
      view.setProperty('backgroundColor', 'gray')

      # Create a grid cell to help layout the view.
      gridCell = TN.cellForView(view,
        layoutMode: 'vertical'
        padding: 10
      )

      gridCell.batchUpdates(->
        # Add the button that will show the action sheet.
        button = new TN.UI.Button(
          title: 'Choose Meal'
          backgroundColor: 'black'
        )
        # Create and add a grid cell for the button that will stretch the
        # button horizontally.
        gridCell.add(new TN.GridCell(
          view: button
          growMode: 'horizontal'
          fixedHeight: 30
        ))

        # Add a spacer between the button and label.
        gridCell.add(new TN.UI.View(height: 20))

        # Add a label (with a cell to grow it) that we will update with the
        # user's choice.
        label = new TN.UI.Label(
          text: ''
          color: 'white'
        )
        gridCell.add(new TN.GridCell(
          view: label
          growMode: 'horizontal'
          fixedHeight: 30
        ))

        # Add a click handler for the button to show the action sheet.
        button.addEventListener('click', ->
          actionSheet = new TN.UI.ActionSheet(title: "Choose your meal")

          addButton = (food, type) ->
            actionSheet.addButton(
              title: food
              type: type
              action: ->
                label.setProperty('text', "Enjoy your #{food.toLowerCase()}!")
            )

          addButton("Hamburger")
          addButton("Hot Dog", 'cancel')
          addButton("Salad", 'destructive')

          actionSheet.show()
        )
      )
  )


