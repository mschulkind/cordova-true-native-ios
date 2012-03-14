pluginID = 'cordovatruenative.http'

nextRequestID = 0
allocateRequestID = ->
  allocatedID = nextRequestID
  nextRequestID++
  "#{allocatedID}"

TN.HTTP =
  fetch: (options) ->
    url = options?.url
    throw "URL required" unless url

    verb = options?.verb ? 'GET'
    throw "Invalid verb '#{verb}'" unless _(['GET', 'POST']).include(verb)

    requestID = allocateRequestID()

    # Convert all values to strings before passing along.
    convertValues = (object) ->
      convertedObject = {}

      for key, objectValue of object
        if objectValue instanceof Array
          # If it's an array, make sure all entries are strings.
          convertedObject[key] = []
          for index, arrayValue of objectValue
            convertedObject[key].push(arrayValue.toString())
        else
          # For everything else, just make sure it's a string.
          convertedObject[key] = objectValue.toString()

      convertedObject

    params = convertValues(options.params) if options?.params
    data = convertValues(options.data) if options?.data

    Cordova.exec(
      options?.successHandler, options?.errorHandler, pluginID, "fetch",
      [
        requestID: requestID
        url: url
        verb: verb
        params: params
        data: data
        timeout: options?.timeout
      ]
    )

    requestID

  abort: (requestID) ->
    Cordova.exec(null, null, pluginID, 'abort', [requestID: requestID])

  openExternalURL: (url) ->
    Cordova.exec(null, null, pluginID, 'openExternalURL', [url: url])
