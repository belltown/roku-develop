module.exports = class RokuDeviceTable

  constructor: ->
    @deviceTable = new Map()

  # Called when an SSDP discovery response is received
  # details -- a DeviceEntry object (defined at the end of this file)
  add: (details) ->
    # Only necessary to update the deviceTable if something has changed
    changed = false

    # Check whether the serial number is already in the table
    if @deviceTable.has details.serialNumber
      # Update an existing deviceTable entry
      deviceEntry = @deviceTable.get details.serialNumber
      updated = @updateDeviceEntry deviceEntry, details
      @deviceTable.set details.serialNumber, deviceEntry
      changed = true if updated
    else
      # New serial number -- add new device
      @deviceTable.set details.serialNumber, new DeviceEntry(details)
      changed = true

    # Check whether the ip address was previously assigned
    # to another device; if so, delete the old entry
    for item in @deviceTable
      # Ignore the current entry
      if item.serialNumber isnt details.serialNumber
        if item.ipAddr is details.ipAddr
          @deviceTable.delete item
          changed = true
          break

    return changed

  # Retrieve the device table entry for a specified serial number
  get: (serialNumber) ->
    @deviceTable.get serialNumber

  isEmpty: ->
    @deviceTable.size is 0

  getValues: ->
    Array.from(@deviceTable.values())

  sortByIPAddress: ->
    Array.from(@deviceTable.values()).sort((a, b) =>
      ipAddrTo32(a.ipAddr) - ipAddrTo32(b.ipAddr))

  fromJsonString: (jsonString) ->
    json = null

    try
      json = JSON.parse jsonString
    catch e
      json = null

    if json
      @deviceTable = new Map(json)
    else
      @deviceTable = new Map()

  toJsonString: ->
    JSON.stringify(Array.from(@deviceTable))

  # Update a device table entry
  # Return true if the updated entry differs from the previous entry
  updateDeviceEntry: (deviceEntry, device) ->
    oldIpAddr       = deviceEntry.ipAddr
    oldFriendlyName = deviceEntry.friendlyName
    oldModelName    = deviceEntry.modelName
    oldModelNumber  = deviceEntry.modelNumber

    # If the IP address has changed, update the device entry with the new addr
    if deviceEntry.ipAddr isnt device.ipAddr
      deviceEntry.ipAddr = device.ipAddr

    # Don't update the friendly name unless it was previously blank,
    # because the user could have updated the friendly name manually
    if deviceEntry.friendlyName is ''
      deviceEntry.friendlyName = device.friendlyName

    # Don't update the table with blank values for model name/number,
    # which would happen if an SSDP Notify was received,
    # but no ECP response could be obtained
    if device.modelName isnt ''
      deviceEntry.modelName = device.modelName

    if device.modelNumber isnt ''
      deviceEntry.modelNumber = device.modelNumber

    # Don't update the deploy flag here, as this is only called
    # when an SSDP response is received

    # Return true if any field has changed in value (SN does not change)
    not ( deviceEntry.ipAddr       is oldIpAddr        and \
          deviceEntry.friendlyName is oldFriendlyName  and \
          deviceEntry.modelName    is oldModelName     and \
          deviceEntry.modelNumber  is oldModelNumber )


# Convert an ip address of the form nnn.nnn.nnn.nnn to a
# 32-bit (unsigned) integer -- used for sorting device list
ipAddrTo32 = (ipAddr) ->
  ip32 = 0
  ma = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.exec ipAddr
  if Array.isArray(ma) and ma.length is 5
    d0 = parseInt(ma[1], 10)
    d1 = parseInt(ma[2], 10)
    d2 = parseInt(ma[3], 10)
    d3 = parseInt(ma[4], 10)
    ip32 = ((d0 * 256 + d1) * 256 + d2) * 256 + d3
  ip32

# The device table is a Map() object with a key of Serial Number
# The value of the Map() object has the following structure
DeviceEntry = (device) ->
  serialNumber: device.serialNumber
  ipAddr:       device.ipAddr
  friendlyName: device.friendlyName
  modelName:    device.modelName
  modelNumber:  device.modelNumber
  deploy:       true
