window.TN = {}

formatPuts = (msg, linePrefix, filterKeys) ->
  if typeof msg == 'object'
    output = "{"

    for key,value of msg
      continue if filterKeys.indexOf(key) != -1

      if typeof value != 'function'
        output += "\n#{linePrefix}  #{key}: "
        valueString = formatPuts(value, linePrefix + "  ", filterKeys)
        if typeof value == 'string'
          valueString = "'#{valueString}'"
        output += valueString

    output += "\n#{linePrefix}}"
  else
    output = msg

  output

window.puts = (msg, filterKeys) ->
  if typeof filterKeys == 'string'
    filterKeys = [filterKeys]
  filterKeys ||= []

  console.log(formatPuts(msg, '', filterKeys))

window.alert = (message) ->
  navigator.notification.alert(message, null, "")
