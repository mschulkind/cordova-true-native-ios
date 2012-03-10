# Borrowed from the coffeescript cookbook at:
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
TN.clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key, value of obj
    newInstance[key] = TN.clone value

  newInstance

# Returns a clone of the given objects with any key-value pairs filtered out
# that the filterCallback returns false for.
TN.cloneWithFilter = (obj, filterCallback) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key, value of obj
    # Give the filter out key/values out based on their non-cloned-and-filtered
    # form.
    if filterCallback(key, value)
      newValue = TN.cloneWithFilter(value, filterCallback)
      # Give the filter a second chance to filter out key/values based on their
      # cloned and filtered form.
      if filterCallback(key, newValue)
        newInstance[key] = newValue
      else
        delete newInstance[key]

  newInstance

TN.ellipsizeString = (string, maxLength) ->
  string = string.substring(0, maxLength)
  if string.length == maxLength
    string += "..."
  string

TN.merge = (source, dest) ->
  for k,v of source
    dest[k] = v
  dest

# Merges keys from source into dest if they don't already exist in dest.
TN.reverseMerge = (source, dest) ->
  for k,v of source
    dest[k] = v unless dest[k]?
  dest

TN.afterDelay = (ms, action) ->
  setTimeout(action, ms)

TN.timeExecution = (name, callback) ->
  before = new Date
  callback()
  after = new Date
  elapsed = after.getTime() - before.getTime()
  puts "#{name} elapsed: #{elapsed}ms"

TN.intWithLeadingZeros = (int, minimumLength) ->
  string = int.toString()
  string = '0' + string while string.length < minimumLength
  string
