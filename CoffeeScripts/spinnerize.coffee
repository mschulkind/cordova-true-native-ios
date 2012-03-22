# Displays a spinner on the given view until it is fully loaded.
#
# Example usage:
# view = new TN.UI.View
# TN.spinnerizeView(view, (removeSpinner) ->
#   TN.backend.getUserDetails('self', (user) ->
#     removeSpinner()
#     displayThe(user)
#   )
# )
TN.spinnerizeView = (view, onShow) ->
  spinner = new TN.UI.Spinner(
    width: 20
    height: 20
    top: 5
    centerX: view.width / 2
  )
  view.add(spinner)

  resizeListener = view.addEventListener('resize', ->
    spinner.setProperty('centerX', view.width / 2)
  )

  removeSpinner = ->
    view.remove(spinner)
    view.removeEventListener('resize', resizeListener)

  onShowWrapper = ->
    view.removeEventListener('show', onShowWrapper)
    onShow(removeSpinner)

  view.addEventListener('show', onShowWrapper)
