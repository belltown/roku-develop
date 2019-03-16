# [roku-develop](https://atom.io/packages/roku-develop)

### an [ATOM editor](https://atom.io/) package to deploy a Roku project to multiple devices

*Automatically (or manually) discover Rokus on the local network.*

*Zip the current Roku project directory.*

*Deploy to multiple Roku devices.*

*Automatically increment manifest build_version.*

*Create a Package file for the currently-deployed application.*

*Switch between associated .xml and .brs files with keyboard shortcut.*

### Install the package in Atom

Go to Settings <kbd>Ctrl+,</kbd> then **Install**. Search for `roku-develop`.

For more info on Atom, read the
[Atom Flight Manual](https://flight-manual.atom.io/).

### Configure settings

Go to Settings <kbd>Ctrl+,</kbd> then **Packages**. Search for `roku-develop`.

Enter the Roku developer settings password. See the Roku
[Developer Setup Guide](https://developer.roku.com/develop/getting-started/setup-guide) for instructions on
setting the Roku developer password.
**Ensure that Developer Mode is enabled for each Roku device.**

`Default Packaging Device` - the SERIAL NUMBER of the default device to be used for packaging, used if more than one device is checked.
If one and only one device is checked in the device list, then the checked device will be used for packaging instead of this default device.
This option avoids having to un-check all but one device when packaging, then re-check them if deploying to multiple devices.

`Increment Manifest build_version` - specifies whether
the manifest file build_version is incremented when the project is deployed:

- Do not increment
- Increment
- Use date: yyyymmdd
- Use date/time: yymmddhhmm

`Save On Deploy` - automatically save the current file
before deployment.

`Send Home Keypress Before Deploy` - send a Home keypress
to the device, followed by a short delay, before uploading the
zip file. This can be used as a workaround to a Roku bug that
causes the device to sometimes re-boot when deploying a Scene Graph
channel. Uncheck this box for faster deployment, provided the Roku does not crash.

`Automatically discover Rokus on the local network` - if checked, will automatically attempt to discover all Rokus on the local network.
If un-checked, will disable automatic discovery, only allowing Roku devices to be manually entered.

#### .rokudevignore

Ignores can optionally be placed in the file `.rokudevignore`. This file should
reside in the same directory as the manifest file.

Rules:

- Lines beginning with a hash (`#`), and blank lines, will not be processed.
- Lines beginning with an exclamation mark (`!`) specify unignored paths.
- All other lines specify ignored paths.
- Any ignored or unignored path name may either be a path name relative to
  .rokudevignore's containing directory (the project root directory), or
  a base name of a file or directory that may match anywhere in the
  directory hierarchy.
- Unignores can be used to explicitly include a file or directory, even if it is
  contained within a directory that is being ignored.
- If a path is both ignored and unignored, then the ignore takes precedence.
- Path separators in .rokudevignore are forward slashes (even on Windows).

### Keyboard shortcuts

roku-develop uses 4 commands: ```roku-develop:toggle```, ```roku-develop:deploy```, ```roku-develop:package```, and ```roku-develop:switch-files```, which may be selected from the Packages > roku-develop menu, or from the context (right-click) menu.

In addition, the following keyboard shortcuts are defined by default:

<kbd>Ctrl+;</kbd> (Ctrl-semicolon) - Toggle device list.

<kbd>Ctrl+Alt+;</kbd> (Ctrl-Alt-semicolon) - Deploy to selected devices.

<kbd>Alt+;</kbd> (Alt-semicolon) - Package the currently-deployed application.

<kbd>Ctrl+Alt+X</kbd> (Ctrl-Alt-x) - Switch between the current component's brs and xml files, if applicable.

If you find that these particular key combinations don't work well with
your keyboard configuration, you can change them:

1. On the roku-develop package Settings page, un-check the 'Enable' box
under Keybindings.

2. Edit your Atom keymap.cson file
(look under **File > Keymap...** or **Edit > Keymap...**),
then add your own keybindings. For example, to use <kbd>Ctrl+7</kbd>, <kbd>Ctrl+8</kbd>,
<kbd>Ctrl+9</kbd> and <kbd>Ctrl+0</kbd> instead, place the following lines at the end of
your keymap.cson file:

```
'atom-workspace':
  'ctrl-7': 'roku-develop:package'
  'ctrl-8': 'roku-develop:toggle'
  'ctrl-9': 'roku-develop:deploy'
  'ctrl-0': 'roku-develop:switch-files'
```

### Usage

<kbd>Ctrl+;</kbd> (Ctrl-semicolon) - Toggle device list.
Wait for devices to be automatically discovered,
then check the boxes to specify devices for deployment.
The state of the device table will be persisted between editor sessions.
Note that if you have multiple Atom editor instances running,
changing a checkbox state in one Atom instance
may or may not be reflected in the other Atom instances.

**By default, all newly-discovered devices are checked.
Uncheck the boxes for devices not to be deployed to.**

**To disable automatic discovery, un-check the Settings option for automatic discovery.**

---

<kbd>Ctrl+Alt+;</kbd> (Ctrl-Alt-semicolon) - Deploy to selected devices.

---

<kbd>Alt+;</kbd> (Alt-semicolon) - Package the currently-deployed application.
- Roku device must have been keyed using `Genkey` or `Rekey`, (see [https://sdkdocs.roku.com/display/sdkdoc/Packaging+Roku+Channels](https://sdkdocs.roku.com/display/sdkdoc/Packaging+Roku+Channels)).
- Application packager password (24 chars, e.g. cmqsu1vhB6Q1VVTHI0eGLp==), must have been entered in Settings.
- If a Default Packaging Device is specified in the Config Settings, it will be used, unless one and only one device is checked.
- Package must first be deployed to the Roku before it can be packaged.
- Package will be written to the same directory as the Zip File Directory specified in Settings.

---

<kbd>Ctrl+Alt+X</kbd> (Ctrl-Alt-x) - Switch between the current component's script (\*.brs) and layout (\*.xml) files.
- If the corresponding file is already open in another tab and/or pane, focus will move to that tab/pane.
- If the file is not open yet, a new tab containing it will be opened under the current active pane.
- If no corresponding file exists (i.e. the current directory contains only a .brs or only an .xml file), no action will be taken.

---

`Add New Device` button can be used to manually add devices not
automatically discovered.
Note that a device will only be listed (and deployed to) if
it responds to ECP requests.

---

`Clear List` button will remove all automatically-discovered and manually-added
devices from the list.
Automatic discovery (if enabled in Settings) will re-add devices.

---

`Hide Unchecked`/`Show Unchecked` button toggles the device list display
to either show only checked devices (Hide Unchecked), or show all devices
(Show Unchecked).

When deploying a project, one of the project's files needs to be open in the
active editor pane on display when the deploy command is issued.
An upward search of the directory tree is performed to locate the Roku
project's directory (the one containing a `source` directory and
`manifest` file).
The Atom editor may have multiple Roku project directories open,
but only the project containing the file currently being edited
will be deployed.
Note that the manifest file must be UTF-8 encoded.

![screenshot](https://github.com/belltown/roku-develop/raw/master/screenshot.png)

### Firewall configuration

All Roku devices on the local network should automatically be discovered
using SSDP M-SEARCH and NOTIFY responses.
If not, then ensure your firewall is configured for automatic device discovery.
This is more likely to be an issue for certain Linux users.

The M-SEARCH responses are UDP unicast packets sent to the ephemeral port
from which the M-SEARCH request originated;
the ephemeral port range may be found by:
```
cat /proc/sys/net/ipv4/ip_local_port_range
```
The NOTIFY responses are UDP multicast packets sent to port 1900.

So in Fedora or CentOS, for example,
the following commands would open these ports:

```
sudo firewall-cmd --permanent --add-port=1900/udp
sudo firewall-cmd --permanent --add-port=32768-61000/udp
sudo firewall-cmd --reload
```

On Ubuntu, the firewall is typically disabled by default.
If not, a rule like this should work:

```
sudo ufw allow proto udp from 192.168.0.0/24 port 1900,32768:60999
sudo ufw reload
```

### Contribute

Some concepts used in this package were taken from the
[roku-deploy](https://atom.io/packages/roku-deploy) Atom package by
[Mike McAulay/mmratio](https://github.com/mmratio).
Thanks for your efforts, Mike.

Thanks to [AhmedGamal-Inmobly](https://github.com/AhmedGamal-Inmobly),
[Rolando Islas](https://github.com/rolandoislas),
and [Michael Meyer](https://github.com/entrez) for their contributions to this package.

Another useful package for Roku development is
[language-brightscript](https://atom.io/packages/language-brightscript),
which provides BrightScript syntax highlighting and snippets.
[language-vb](https://atom.io/packages/language-vb)
also works well with BrightScript.

Feel free to use Github
[Issues](https://github.com/belltown/roku-develop/issues) or
[Pull Requests](https://github.com/belltown/roku-develop/pulls)
for bug reports and enhancement requests, etc.

You may also contact the roku-develop author,
[belltown](https://forums.roku.com/memberlist.php?mode=viewprofile&u=37784),
through the [Roku Forums](https://forums.roku.com/viewforum.php?f=34).
