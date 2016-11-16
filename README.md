# [roku-develop](https://atom.io/packages/roku-develop)

### an [ATOM editor](https://atom.io/) package to deploy a Roku project to multiple devices

*Automatically discover Rokus on the local network.*

*Zip the current Roku project directory.*

*Deploy to multiple Roku devices.*

*Automatically increment manifest build_version.*

### Install the package in Atom

Go to Settings <kbd>Ctrl+,</kbd> then **Install**. Search for `roku-develop`.

For more info on Atom, read the
[Atom Flight Manual](http://flight-manual.atom.io/).

### Configure settings

Go to Settings <kbd>Ctrl+,</kbd> then **Packages**. Search for `roku-develop`.

Enter the Roku developer settings password. See the Roku
[Developer Setup Guide](https://github.com/rokudev/docs/blob/master/develop/getting-started/setup-guide.md#1-setup-your-roku-device-to-enable-developer-settings) for instructions on
setting the Roku developer password.
**Ensure that Developer Mode is enabled for each Roku device.**

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

### Keyboard shortcuts

roku-develop uses two commands, ```roku-develop:toggle```
and ```roku-develop:deploy```,
which may be selected from the Packages > roku-develop menu,
or from the context (right-click) menu.

In addition, the following keyboard shortcuts are defined by default:

<kbd>Ctrl+;</kbd> (Ctrl-semicolon) - Toggle device list.

<kbd>Ctrl-Alt+;</kbd> (Ctrl-Alt-semicolon) - Deploy to selected devices.

If you find that these particular key combinations don't work well with
your keyboard configuration, you can change them:

1. On the roku-develop package Settings page, un-check the 'Enable' box
under Keybindings.

2. Edit your Atom keymap.cson file
(look under **File > Keymap...** or **Edit > Keymap...**),
then add your own keybindings. For example, to use <kbd>Ctrl+8</kbd> and
<kbd>Ctrl+9</kbd> instead, place the following lines at the end of
your keymap.cson file:

```
'atom-workspace':
  'ctrl-8': 'roku-develop:toggle'
  'ctrl-9': 'roku-develop:deploy'
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

---

<kbd>Ctrl-Alt+;</kbd> (Ctrl-Alt-semicolon) - Deploy to selected devices.

---

`Add New Device` button can be used to manually add devices not
automatically discovered.
Note that a device will only be listed (and deployed to) if
it responds to ECP requests.

---

`Clear List` button will remove all automatically and manually-discovered
devices from the list. Automatic discovery will re-add devices,
although it may be necessary to restart Atom.

---

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
