TN.cellForView = (view, options) ->
  options || = {}
  new TN.GridCell(
    _(
      inheritViewSizeMode: 'both'
      view: view
    ).extend(options)
  )

TN.glueViews = (parent, child) ->
  parentCell = TN.cellForView(parent)

  parentCell.add(
    new TN.GridCell(
      growMode: 'both'
      view: child
    )
  )

  # TODO:(mschulkind) Remove this after grid cell resize watching.
  parent.addEventListener('resize', ->
    parentCell.layout()
  )

TN.createGrowingLabelCell = (options) ->
  label = new TN.UI.Label(
    _(options).defaults(
      text: 'ZZZ'
    )
  )
  label.sizeToFit()
  labelCell = new TN.GridCell(
    growMode: 'horizontal'
    inheritViewSizeMode: 'height'
    view: label
  )

  labelCell

TN.showConfirmDialog = (options) ->
  title = options?.title ? ''

  callback = (index) ->
    # Check if OK button was clicked (index 2).
    if index == 2
      options?.onConfirm?()

  navigator.notification.confirm("", callback, title, 'Cancel,OK')
