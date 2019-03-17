## v0.1.12 - Add a shortcut to switch between brs/xml files

- Add a shortcut to switch between brs/xml files (PR #9)
- Update copyright year

## v0.1.11 - Add the Default Package Device configuration setting

- Add the Default Package Device configuration setting (serial number of default packaging device,
  used for packaging unless the device list has one and only one device checked)
- electron-config is now electron-store
- Latest version of Archiver now uses local time for zip'd files instead of UTC
- Use latest versions of all dependent packages

## v0.1.10 - Add Package command and project-specific ignores

- Add .rokudevignore ignore file parsing
- Add package command

## v0.1.9 - Increase request timeout when uploading to device

- Change request timeout from 15 to 60 seconds when uploading to device
- Use latest versions of all dependent packages

## v0.1.8 - Implement scrollbars for device table

- Add scrollbars, if necessary, to Roku device list
- Add Show/Hide Unchecked button to device list
- Implement 15 second timeout when attempting to connect
- Update documentation link to Roku Developer Setup Guide

## v0.1.7 - Resolve symbolic links in zip file

- Handle symbolic links in the project directory

## v0.1.6 - Allow auto-discovery to be disabled

- Implement Settings option to disable auto-discovery

## v0.1.5 - Update dependencies

- Use the latest versions of all dependent packages
- Update copyright year

## v0.1.4 - Handle HTTP code 202 from Roku device

- When deploying, treat an HTTP status code 202 (Accepted) the same as a code 200 (OK)
- Update copyright year

## v0.1.3 - Minor changes to device discovery

- Apply a timeout when creating socket to send ECP request to discovered device.
- Use `reuseAddr: true` option when opening notify-socket to allow other applications to also listen for SSDP NOTIFY responses.

## v0.1.2 - Improve error messages

If the current file cannot be saved, or the manifest file cannot be updated, then output a more descriptive error message.

## v0.1.1 - Add Keybindings section to README file

The README documentation has been updated to describe how to change the default keybindings if the default <kbd>Ctrl+;</kbd> or <kbd>Ctrl+Alt+;</kbd> keybindings are undesirable. On certain Windows keyboard configurations, Ctrl+Alt+; generates a Unicode "¶" character.

## v0.1.0 - Initial deploy to Atom.io

Initial deploy to Atom.io.

## v0.0.0 - Initial release

Initial release.
