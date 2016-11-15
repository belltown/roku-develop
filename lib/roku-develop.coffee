{CompositeDisposable} = require 'atom'
{File}                = require 'atom'
fs                    = require 'fs'
path                  = require 'path'
request               = require 'request'
Archiver              = require 'archiver'
Config                = require 'electron-config'
RokuDevelopView       = require './roku-develop-view.coffee'
RokuDeviceTable       = require './roku-develop-devtable.coffee'
RokuSSDP              = require './roku-develop-ssdp.coffee'

module.exports        = RokuDevelop =

  excludedPaths:      null
  zipFileDirectory:   null
  rokuUserId:         null
  rokuPassword:       null
  manifestBuild:      null
  saveOnDeploy:       null
  homeBeforeDeploy:   null
  rokuDeviceTable:    null
  rokuDevelopView:    null
  subscriptions:      null
  myConfig:           null
  panel:              null
  rokuIPList:         null
  projectDirectory:   null
  zipFilePath:        null

  # Package config schema (Settings)
  config:
    excludedPaths:
      title: 'Excluded Paths (comma-separated list)'
      description: 'dot-files and Zip File Directory
                    are automatically excluded'
      type: 'string'
      default: ''
      order: 1
    zipFileDirectory:
      title: 'Zip File Directory (absolute path or project dir relative path)'
      description: 'parent directory must already exist'
      type: 'string'
      default: 'out'
      order: 2
    rokuUserId:
      type: 'string'
      default: 'rokudev'
      order: 3
    rokuPassword:
      type: 'string'
      default: ''
      order: 4
    manifestBuild:
      title: 'Increment manifest build_version'
      type: 'integer'
      default: 0
      enum: [
        {value: 0, description: 'Do not increment'}
        {value: 1, description: 'Increment'}
        {value: 2, description: 'Use date: yyyymmdd'}
        {value: 3, description: 'Use date/time: yymmddhhmm'}
      ]
      order: 5
    saveOnDeploy:
      title: 'Save On Deploy (saves current file before deployment)'
      type: 'boolean'
      default: true
      order: 6
    homeBeforeDeploy:
      title: 'Send Home Keypress Before Deploy'
      description: 'Use if deploying a Scene Graph channel
                    causes the Roku to crash'
      type: 'boolean'
      default: false
      order: 7

  #
  # Invoked by Atom one time only, when an activation command is issued
  # Activation commands are specified in package.json
  #
  activate: (state) ->
    # Get Atom config data, and add event-handlers for config updates

    @excludedPaths    = atom.config.get 'roku-develop.excludedPaths'
    @zipFileDirectory = atom.config.get 'roku-develop.zipFileDirectory'
    @rokuUserId       = atom.config.get 'roku-develop.rokuUserId'
    @rokuPassword     = atom.config.get 'roku-develop.rokuPassword'
    @manifestBuild    = atom.config.get 'roku-develop.manifestBuild'
    @saveOnDeploy     = atom.config.get 'roku-develop.saveOnDeploy'
    @homeBeforeDeploy = atom.config.get 'roku-develop.homeBeforeDeploy'

    atom.config.observe 'roku-develop.excludedPaths', (newValue) =>
      @excludedPaths = newValue

    atom.config.observe 'roku-develop.zipFileDirectory', (newValue) =>
      @zipFileDirectory = newValue

    atom.config.observe 'roku-develop.rokuUserId', (newValue) =>
      @rokuUserId = newValue

    atom.config.observe 'roku-develop.rokuPassword', (newValue) =>
      @rokuPassword = newValue

    atom.config.observe 'roku-develop.manifestBuild', (newValue) =>
      @manifestBuild = newValue

    atom.config.observe 'roku-develop.saveOnDeploy', (newValue) =>
      @saveOnDeploy = newValue

    atom.config.observe 'roku-develop.homeBeforeDeploy', (newValue) =>
      @homeBeforeDeploy = newValue

    # Use a config file in Atom's config directory to persist the device table
    @myConfig = new Config({name: 'roku-develop-config'})
    console.log 'Using config file:', @myConfig.path

    # Construct an empty device table
    @rokuDeviceTable = new RokuDeviceTable

    # Restore device table from config file
    deviceTableJsonString = @myConfig.get 'deviceTableJsonString'
    @rokuDeviceTable.fromJsonString deviceTableJsonString

    # The view sets up the DOM element used for the displayed device list
    @rokuDevelopView = new RokuDevelopView(@newDeviceCallback.bind(this),
                                           @clearDevicesCallback.bind(this))

    # Place the view's DOM element in a panel at the bottom of the editor pane
    @panel = atom.workspace.addBottomPanel({item: @rokuDevelopView.getElement()
                                            , visible: false})

    # Update the view with the saved device table
    @rokuDevelopView.update @rokuDeviceTable

    # Facilitate cleanup of subscribed events
    @subscriptions = new CompositeDisposable

    # Register commands

    @subscriptions.add atom.commands.add  'atom-workspace',
                                          'roku-develop:toggle': => @toggle()

    @subscriptions.add atom.commands.add  'atom-workspace',
                                          'roku-develop:deploy': => @deploy()

    # Initiate device discovery
    # 'bind' ensures callback executes in the context of the main package code
    RokuSSDP.discover @discoveryCallback.bind(this)

  #
  # Invoked by Atom upon shutdown
  #
  deactivate: ->
    # Persist the device table to the config file
    @myConfig.set 'deviceTableJsonString', @rokuDeviceTable.toJsonString()
    @subscriptions.dispose()
    @panel.destroy()
    @rokuDevelopView.destroy()

  #
  # Called by Atom before the package is deactivated
  # Any JSON returned here will be passed as an argument to activate()
  # the next time the package is loaded
  #
  serialize: ->

  #
  # Called from the view when a new device has been manually entered
  #
  newDeviceCallback: (ip) ->
    if @validIP ip
      RokuSSDP.ecp ip, @discoveryCallback.bind(this)
    else
      console.warn 'newDeviceCallback - invalid IP address', ip

  #
  # Called from the view when the Clear List button is pressed
  #
  clearDevicesCallback: ->
    @rokuDeviceTable = new RokuDeviceTable

  #
  # Invoked when the roku-develop:toggle command is issued
  #
  toggle: ->
    if @panel.isVisible() then @panel.hide() else @panel.show()

  #
  # Invoked when the roku-develop:deploy command is issued
  #
  deploy: ->
    # Make sure the password is set up
    if not @rokuPassword
      atom.notifications.addWarning 'You must set your password
                                     on the Settings page (Ctrl+comma)',
                                    {
                                      dismissable: true
                                      detail: 'Go to Settings page > Packages
                                              > roku-develop'
                                    }
      return

    # Check that at least one device exists
    if @rokuDeviceTable.getValues().length < 1
      atom.notifications.addWarning 'No devices found', {dismissable: true}
      return

    # Get the list of deployment ip addresses
    @rokuIPList = (entry.ipAddr for entry in @rokuDeviceTable.getValues() \
                    when entry.deploy)

    # Check that at least one discovered device is selected
    if @rokuIPList.length < 1
      atom.notifications.addWarning 'No devices marked for deployment',
                                    {dismissable: true}
      return

    # Compress the project directory, deploying when finished
    try
      @compressProject()
    catch e
      console.warn 'Exception when creating zip file: %O', e
      atom.notifications.addError 'Exception when creating zip file',
                                  {dismissable: true, detail: e.message}

  #
  # Called from RokuSSDP whenever a device has been discovered
  #
  discoveryCallback: (details) ->
    # Update the device table with the new device details
    deviceTableChanged = @rokuDeviceTable.add details
    if deviceTableChanged
      # Update the view only if the device table has changed
      @rokuDevelopView.update @rokuDeviceTable
      # Persist the device table to the config file
      @myConfig.set 'deviceTableJsonString', @rokuDeviceTable.toJsonString()

  #
  # Return true if an ip address is of the form: aaa.bbb.ccc.ddd
  #
  validIP: (ip) ->
    /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test ip

  #
  # Get the name of the folder containing the current file being edited
  # Check that the folder contains a 'source' directory
  # If the folder does not contain a 'source' directory,
  # search up the directory tree to find one
  # This allows the user to have multiple Roku projects open in Atom
  #
  compressProject: ->

    # Get the active TextEditor object
    activeTextEditor = atom.workspace.getActiveTextEditor()

    # If we're on the Settings View or Markdown View,
    # for example, there won't be an active TextEditor
    if not activeTextEditor
      atom.notifications.addWarning 'Project can only be deployed
                                    from within an Editor window',
                                    {dismissable: true}
      return

    # Get the path of the file being edited
    activePath = activeTextEditor.getPath()

    # There won't be an active file if editing a new 'untitled' file
    if not activePath
      atom.notifications.addWarning 'Project can only be deployed
                                    when editing an existing project file',
                                    {dismissable: true}
      return

    # Create a File object so we can get the current file's parent directory
    activeFile = new File activePath, false

    if not activeFile
      atom.notifications.addError 'Unable to create File obj from path name',
                                  {dismissable: true}
      return

    # Get the current file's parent directory
    @projectDirectory = activeFile.getParent()

    # Search up the filesystem hierarchy looking for a 'source' directory
    while not @projectDirectory.isRoot() and
          not @projectDirectory.getSubdirectory('source').existsSync()
      @projectDirectory = @projectDirectory.getParent()

    # Don't attempt to compress a project without a 'source' directory
    if not @projectDirectory.getSubdirectory('source').existsSync()
      atom.notifications.addWarning 'Cannot find project source directory',
                        {detail: 'Open a project file before deploying',
                        dismissable: true}
      return

    # Determine the zip file's path name, creating the directory if necessary
    @zipFilePath = @getZipFilePath()
    if not @zipFilePath
      return

    # Save the file -- this will update the timestamp even if nothing changed
    if @saveOnDeploy
      activeTextEditor.save()

    # Increment the build number in the manifest file, then continue deployment
    @incrementManifestBuild()

  #
  # Auto-increment the manifest build number if necessary, then deploy
  #
  incrementManifestBuild: ->

    # Read the manifest file; don't compress unless manifest is found
    manifestPath = path.join @projectDirectory.getRealPathSync(), 'manifest'
    fs.readFile manifestPath, 'utf8', (e, data) =>
      if e
        console.warn 'Error reading manifest file: %O', e
        atom.notifications.addWarning 'Unable to read manifest file',
                                      {dismissable: true, detail: e.message}
      else
        # 0 => Don't increment build_version
        # 1 => Increment build_version
        # 2 => Use date as build_version
        # 3 => Use date/time as build_version
        if @manifestBuild < 1 or @manifestBuild > 3
          @createZip()
        else
          reBuildVersion = /^build_version\s*=(.*)$/im
          ma = reBuildVersion.exec data
          if Array.isArray(ma) and ma.length is 2
            if @manifestBuild is 1
              oldBuildVersion = ma[1]
              newBuildVersion = parseInt(oldBuildVersion, 10) + 1
              newBuildVersion = 0 if isNaN(newBuildVersion)
            else if @manifestBuild is 2
              newBuildVersion = @dateNowFormat()
            else
              newBuildVersion = @dateTimeNowFormat()

            data = data.replace reBuildVersion,
                                'build_version=' + newBuildVersion
            fs.writeFile manifestPath, data, 'utf8', (e) =>
              if e
                console.warn 'Error writing manifest file: %O', e
                atom.notifications.addError 'Unable to write manifest file',
                                        {dismissable: true, detail: e.message}
              else
                @createZip()
          else
            atom.notifications.addWarning 'No manifest build_version found',
                                          {dismissable: true}

  createZip: ->

    # Archiver writes to a writeable stream
    outputStream = fs.createWriteStream @zipFilePath

    # When the project finishes compressing, the output stream will close
    # Deploy the compressed zip file to the Roku devices
    outputStream.on 'close', =>
      @deployZip()

    outputStream.on 'error', (e) =>
      atom.notifications.addError 'Archive output stream error',
                                  {dismissable: true, detail: e.message}
      archive?.abort()

    # Construct a list of excluded paths, trimming whitespace from each item
    excludedPathList = (item.trim() for item in @excludedPaths.split ',')

    # Use the archiver package to create a zip of the project directory
    # Note that the forceLocalTime zip option doesn't appear to work,
    # so the files in the zip bundle may have UTC timestamps
    archive = Archiver('zip', {forceLocalTime: true})

    archive.on 'error', (e) =>
      console.warn 'Archive error: %O', e
      atom.notifications.addError 'Archive error',
                                  {dismissable: true, detail: e.message}
      return false

    archive.pipe outputStream

    # Compile a list of files and directories to be compressed
    for entry in @projectDirectory.getEntriesSync()
      baseName = entry.getBaseName()
      pathname = entry.getRealPathSync()
      # Ignore hidden files and directories, and excluded files and directories
      if  not (baseName.startsWith '.') and (baseName not in excludedPathList)
        if entry.isFile()
          # Queue a file for compression, but not the zip file itself
          if pathname isnt @zipFilePath
            archive.file pathname, {name: baseName}
        else if entry.isDirectory()
          # Queue a directory for compression, but not the zip file directory
          if pathname isnt path.dirname @zipFilePath
            archive.directory pathname, baseName

    # Finish the compression, calling the output stream's close handler
    archive.finalize()

    return true

  #
  # Determine the pathname used for the compressed zip file
  #
  getZipFilePath: ->
    zipFileDirectoryNorm = path.normalize @zipFileDirectory.trim()
    if path.isAbsolute zipFileDirectoryNorm
      zipDirectoryPath = zipFileDirectoryNorm
    else
      zipDirectoryPath = path.join @projectDirectory.getRealPathSync()
                                   , zipFileDirectoryNorm

    zipFilePath = path.join zipDirectoryPath, 'bundle.zip'

    # Check if output directory already exists
    try
      stats = fs.statSync zipDirectoryPath
    catch e
      stats = null

    # Create output directory if it does not already exist
    if not stats or not stats.isDirectory()
      console.log zipDirectoryPath + ' does not exist or is not directory'
      try
        fs.mkdirSync zipDirectoryPath
      catch e
        console.warn 'Unable to create output directory: %O', e
        atom.notifications.addError 'Unable to create output directory',
                                    {dismissable: true, detail: e.message}
        return ''

    return zipFilePath

  #
  # Deploy the zip file to all selected Roku devices
  #
  deployZip: ->
    atom.notifications.addInfo 'Deploying project to selected devices'
    for ip in @rokuIPList
      if @homeBeforeDeploy
        @homeKeypress ip, 2
      else
        @uploadToDevice(ip)

  #
  # Send an ECP command so device exits to Home screen before deploying
  # Use two Home keypresses: one to exit the screensaver, one to get to Home
  #
  homeKeypress: (ip, num) ->

    url = "http://#{ip}:8060/keypress/Home"

    request.post(url, (error, response, body) =>
      if error
        atom.notifications.addWarning 'Connect error: ' + error.message,
                                      {dismissable: true}
      else if not response
        atom.notifications.addWarning 'No response received from ' + ip,
                                      {dismissable: true}
      else if response.statusCode isnt 200
        atom.notifications.addWarning 'Bad response code ' +
                                      response.statusCode +
                                      ' from ' + ip, {dismissable: true}
      else
        if --num > 0
          # First Home keypress exits screensaver, 2nd one exits channel
          @homeKeypress ip, num
        else
          # Delay before uploading package to device
          setTimeout ( => @uploadToDevice(ip) ), 2500
    )

    return

  #
  # Upload the compressed zip file to a Roku device
  #
  uploadToDevice: (ip) ->
    url = "http://#{ip}/plugin_install"

    formData =
      mysubmit: 'Replace'
      archive: fs.createReadStream @zipFilePath

    auth =
      'user': @rokuUserId
      'pass': @rokuPassword
      'sendImmediately': false

    request.post {url: url, formData: formData, auth: auth}
                  ,(error, response, body) =>
      console.log 'error', error
      console.log 'response', response
      console.log 'body', body
      if error
        atom.notifications.addWarning 'Upload error for ' + ip +
                                      ' ' + error.message,
                                      {dismissable: true}
      else if not response
        atom.notifications.addWarning 'No upload response from ' + ip,
                                      {dismissable: true}
      else if response.statusCode is 401
        atom.notifications.addWarning 'Authorization error ' +
                                      response.statusCode + ' from ' + ip,
                                      {
                                        dismissable: true,
                                        detail: 'Make sure you entered
                                                your Roku user id and password
                                                \non the Settings page.'
                                      }
      else if response.statusCode isnt 200
        atom.notifications.addWarning 'Bad upload response code ' +
                                      response.statusCode + ' from ' + ip,
                                      {dismissable: true}
      else
        # Look for Roku.Message in the response body for non-legacy Rokus
        msgList = []
        re = /'Roku\.Message'[\s\S]*?'Set message content'[\s\S]+?'([^']+)'/ig
        while ma = re.exec body
          if Array.isArray(ma) and ma.length is 2
            msgList.push ma[1]

        # Handle responses from legacy Roku devices
        if msgList.length < 1
          re = /<font color="red">([\s\S]+?)<\/font>/ig
          while ma = re.exec body
            if Array.isArray(ma) and ma.length is 2
              msgList.push ma[1]

        # Display Atom notification for each message
        for msg in msgList
          if /fail/i.test msg
            atom.notifications.addWarning ip+ ': ' + msg, {dismissable: true}
          else if /received/i.test msg
            atom.notifications.addSuccess ip + ': ' + msg
          else
            atom.notifications.addInfo ip + ': ' + msg

  #
  # Get local date in the form yyyymmdd
  #
  dateNowFormat: ->
    dt = new Date()

    (@zeroFill dt.getFullYear(), 4) +
    (@zeroFill dt.getMonth() + 1, 2) +
    (@zeroFill dt.getDate(), 2)

  #
  # Get local date/time in the form yymmddhhmmss
  #
  dateTimeNowFormat: ->
    dt = new Date()

    (@zeroFill dt.getFullYear(), 2) +
    (@zeroFill dt.getMonth() + 1, 2) +
    (@zeroFill dt.getDate(), 2) +
    (@zeroFill dt.getHours(), 2) +
    (@zeroFill dt.getMinutes(), 2)

  #
  # Return a string of 'width' chars padded with leading zeroes
  #
  zeroFill: (number, width) ->
    ('0'.repeat(width - 1) + number).slice(-width)
