{CompositeDisposable} = require 'atom'

module.exports = class RokuDevelopView

  constructor: (newDeviceCallback, clearDevicesCallback) ->
    @subscriptions = new CompositeDisposable

    # Root element; style is defined in /styles/roku-develop.less
    @element = document.createElement 'div'
    @element.classList.add 'roku-develop'

    @deviceContainer = document.createElement 'div'

    # Input text field (initially hidden) used to manually add an ip address
    # Add New Device button displays it; ESC key hides it
    ipInputContainer = document.createElement 'div'
    ipInputContainer.classList.add 'ipInputContainer'

    ipLabel = document.createElement 'label'
    ipLabel.appendChild document.createTextNode('Enter IP Address (then Enter
                                                to accept, Esc to cancel)')
    ipInput = document.createElement 'input'
    ipInput.type = 'text'
    # Backspace and delete keys won't work unless native-key-bindings used
    ipInput.classList.add 'native-key-bindings'
    ipInput.addEventListener 'keydown', (e) =>
      if e.code is 'Enter'
        ipAddr = ipInput.value.trim()
        if not ipAddr
          ipInputContainer.style.display = 'none'
        else if /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test ipAddr
          newDeviceCallback ipAddr
          ipInputContainer.style.display = 'none'
          atom.notifications.addInfo 'Attempting to locate ' + ipAddr
        else
          atom.notifications.addWarning 'Invalid IP address: ' + ipAddr
      else if e.code is 'Escape'
        ipInput.value = ''
        ipInputContainer.style.display = 'none'

    ipLabel.appendChild ipInput
    ipInputContainer.appendChild ipLabel
    @element.appendChild ipInputContainer

    # Contains the button group and device list panel
    buttonAndDeviceContainer = document.createElement 'div'
    buttonAndDeviceContainer.classList.add 'buttonAndDeviceContainer'

    buttonContainer = document.createElement 'div'
    buttonContainer.classList.add 'buttonContainer'

    buttonRow1 = document.createElement 'div'
    addButton = document.createElement 'button'
    addButton.appendChild document.createTextNode 'Add Device'
    addButton.classList.add 'btn', 'btn-primary'
    @subscriptions.add atom.tooltips.add(addButton
      , { title: 'Manually add device if not automatically discovered'
        , delay: { 'show': 100, 'hide': 100 }
        , trigger: 'hover'})
    addButton.addEventListener 'click', () =>
      if ipInputContainer.style.display is 'block'
        ipInputContainer.style.display = 'none'
      else
        ipInputContainer.style.display = 'block'
        ipInput.focus()
    buttonContainer.appendChild addButton
    buttonRow1.appendChild addButton
    buttonContainer.appendChild buttonRow1

    buttonRow2 = document.createElement 'div'
    clearButton = document.createElement 'button'
    clearButton.appendChild document.createTextNode 'Clear List'
    clearButton.classList.add 'btn', 'btn-primary'
    @subscriptions.add atom.tooltips.add(clearButton
      , { title: 'Clear device list'
        , delay: { 'show': 100, 'hide': 100 }
        , trigger: 'hover'})
    clearButton.addEventListener 'click', () =>
      clearDevicesCallback()
      @update(null)
    buttonContainer.appendChild clearButton
    buttonRow2.appendChild clearButton
    buttonContainer.appendChild buttonRow2

    buttonAndDeviceContainer.appendChild buttonContainer
    buttonAndDeviceContainer.appendChild @deviceContainer

    @element.appendChild buttonAndDeviceContainer

  # Called from main code when adding the view as an atom panel
  getElement: ->
    @element

  # Called for any change in the device table, e.g. a new device discovered
  # The html for the complete device table is re-created from scratch
  update: (rokuDeviceTable) ->
    # Remove all children of the device container
    while @deviceContainer.firstChild
      @deviceContainer.removeChild @deviceContainer.firstChild

    if not rokuDeviceTable or rokuDeviceTable.isEmpty()
      noDevice = document.createElement 'div'
      noDevice.appendChild document.createTextNode 'No devices found yet ...'
      @deviceContainer.appendChild noDevice
    else
      table = document.createElement 'table'
      table.classList.add 'deviceTable'
      @subscriptions.add atom.tooltips.add(table
        , { title: '<code>Ctrl-Alt-;</code> to deploy to checked devices'
          , delay: { 'show': 100, 'hide': 100 }
          , trigger: 'hover'
          , html: true})

      for roku in rokuDeviceTable.sortByIPAddress()
        # 'do' to ensure correct 'roku' variable instance referenced in event
        do (roku) ->
          checkbox = document.createElement 'input'
          checkbox.classList.add 'input-checkbox'
          checkbox.type = 'checkbox'
          checkbox.checked = roku.deploy
          checkbox.addEventListener 'click', () =>
            roku.deploy = checkbox.checked

          tr              = document.createElement 'tr'
          tdCheckbox      = document.createElement 'td'
          tdIpAddr        = document.createElement 'td'
          tdSerialNumber  = document.createElement 'td'
          tdModelNumber   = document.createElement 'td'
          tdModelName     = document.createElement 'td'
          tdFriendlyName  = document.createElement 'td'

          tdCheckbox.appendChild      checkbox
          tdIpAddr.appendChild        document.createTextNode(roku.ipAddr)
          tdSerialNumber.appendChild  document.createTextNode(roku.serialNumber)
          tdModelNumber.appendChild   document.createTextNode(roku.modelNumber)
          tdModelName.appendChild     document.createTextNode(roku.modelName)
          tdFriendlyName.appendChild  document.createTextNode(roku.friendlyName)

          tr.appendChild tdCheckbox
          tr.appendChild tdIpAddr
          tr.appendChild tdSerialNumber
          tr.appendChild tdModelNumber
          tr.appendChild tdModelName
          tr.appendChild tdFriendlyName

          table.appendChild tr

      @deviceContainer.appendChild table

  destroy: ->
    @subscriptions.dispose()
    while @element.firstChild
      @element.removeChild @element.firstChild
    @element.remove()
