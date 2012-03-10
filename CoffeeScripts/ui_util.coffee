TN.showConfirmDialog = (options) ->
  title = options?.title ? ''

  callback = (index) ->
    # Check if OK button was clicked (index 2).
    if index == 2
      options?.onConfirm?()

  navigator.notification.confirm("", callback, title, 'Cancel,OK')
