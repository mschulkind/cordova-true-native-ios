TN.UI.PickerView = class PickerView extends TN.UI.View
  PLUGIN_NAME: 'pickerview'

  constructor: (options) ->
    super

    delete @height

    @entries =
      if options?.entries?
        _(options.entries).clone()
      else
        []
    
    @selectedRow = options?.selectedRow
