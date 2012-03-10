TN.UI = {}

# Maps tnUIID -> Component. This is used to find components by tnUIID as well
# as keep track of which have been created on the native side.
TN.UI.componentMap = componentMap = {}

TN.UI.registerComponent = (component) ->
  throw "missing tnUIID" unless component.tnUIID
  componentMap[component.tnUIID] = component

TN.UI.unregisterComponent = (component) ->
  throw "can't find component" unless componentMap[component.tnUIID]?
  delete componentMap[component.tnUIID]

TN.UI.Component = class Component extends TN.Listenable
  PLUGIN_NAME = 'component'
  @nextUIID = 0

  constructor: (options) ->
    super

    @tnUIID = @allocateUIID()

    # @userData and @private are defined as functions, but used as objects so
    # that they get filtered out by JSON.stringify().
    @userData = ->
    TN.merge(options.userData, @userData) if options?.userData?

    # This is for use internally by a component to store anything that is not
    # part of the state that gets sent to the native code.
    @private = ->

  allocateUIID: ->
    allocatedID = Component.nextUIID
    Component.nextUIID++
    "#{allocatedID}"

  getProperties: (names, onDone) ->
    if componentMap[@tnUIID]?
      localOnDone = (properties) =>
        TN.merge(properties, this)
        onDone?()

      PhoneGap.exec(
        localOnDone, null, @pluginID, 'getProperties',
        [propertyNames: names, componentID: @tnUIID])
    else
      # If the component is not yet registered (and therefor created on the
      # native side), there's no need to pass on the request since the answer
      # will be the same.
      onDone?()

  getProperty: (name, onDone) ->
    @getProperties([name], onDone)

  setProperties: (properties, onDone) ->
    # Only send properties that have changed.
    changedProperties = {}
    changedCount = 0
    for key, value of properties
      if this[key] != value
        changedProperties[key] = value
        this[key] = value
        changedCount++

    # No need to tell the native side unless at least one property has been
    # updated and the component has already been registered/created.
    if changedCount != 0 && componentMap[@tnUIID]?
      PhoneGap.exec(
        onDone, null, @pluginID, 'setProperties',
        [properties: changedProperties, componentID: @tnUIID])
    else
      onDone?()

  setProperty: (name, value) ->
    update = {}
    update[name] = value
    @setProperties(update)

  registerSelfAndDescendants: ->
    TN.UI.registerComponent(this)

  unregister: ->
    @fireEvent("destroy")
    TN.UI.unregisterComponent(this)

  putsSelf: ->
    puts this

  noop: (onDone) ->
    PhoneGap.exec(onDone, null, @pluginID, 'noop', [])
