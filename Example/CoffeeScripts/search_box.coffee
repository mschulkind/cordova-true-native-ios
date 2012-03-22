App.createSearchBoxHeaderView = (options) ->
  hint = options?.hint
  onChange = options?.onChange
  onDone = options?.onDone

  textField = new TN.UI.TextField(
    hint: hint
    borderWidth: 1
    borderColor: 'black'
    borderRadius: 15
    backgroundColor: 'white'
    leftView: new TN.UI.View(width: 10)
  )

  textField.addEventListener('change', (e) -> onChange?(e))
  textField.addEventListener('done', (e) -> onDone?(e))

  headerCell = new TN.GridCell(
    padding: 10
    inheritViewSizeMode: 'width'
    fixedHeight: 50
    view: new TN.UI.View(
      backgroundColor: 'gray'
    )
  )

  # Wait until the parent tableview resizes us before adding the textField.
  headerCell.view.addEventOnceListener('resize', ->
    headerCell.add(new TN.GridCell(
      growMode: 'both'
      view: textField
    ))
  )

  headerCell.view
