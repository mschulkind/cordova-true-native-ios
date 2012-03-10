TN.UI.DatePickerView = class DatePickerView extends TN.UI.View
  PLUGIN_NAME = 'datepickerview'

  constructor: (options) ->
    super
    @pluginID = PLUGIN_ID

    @date = options?.date?.getTime()
    @minimumDate = options?.minimumDate?.getTime()
    @maximumDate = options?.maximumDate?.getTime()

  getProperties: (names, onDone) ->
    localOnDone = =>
      if _(names).include('date')
        # Convert from milliseconds to a Date object.
        @date = new Date(@date)

      onDone?()

    super(names, localOnDone)

