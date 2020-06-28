# Description

`tofu` is a shell based window manager for x11fs. It uses [x11fs](https://github.com/periish/x11fs) to parse events and control windows. 
`tofu` is built to be easily extensible, and scriptable. It is a simple shell script itself.
`tofc` is a program that can be used in tandem with `tofu`. It controls windows.
`tofu` on it's own does not enforce any particular behaviour for windows, however some example workflows exist in the [contrib](contrib) directory.
`tofu` does not handle keybinds - [sxhkd](https://github.com/baskerville/sxhkd) or XBindkeys is reccomended.

# Installation
`tofu` requires x11fs(https://github.com/periish/x11fs) to function. Build instructions for x11fs are provided within it's repository.
To install `tofu`, all you need to do is copy the `tofc` and `tofu` executables to a directory in your `$PATH`.
If you use a display manager, you can copy `tofu.desktop` to `/usr/share/xsessions` to have it available in your login screen.

# Configuration
`tofu`'s configuration is located in `$XDG_CONFIG_HOME/tofu`, or `$HOME/.config/tofu` if unset.
The configuration files `autorun` and `end` are executables that are executed by the wm when it runs and when it exits, respectively.
`conf` is a file that may be used by some extensions or hooks, but it is not enforced.

# Files
`tofu` creates various files on the disk. These files will be placed in the `$WM` directory. 
If `$WM` is unset, `tofu` will default to `$HOME/.tofu`
The files are as follows:
`fs/` - `tofu` mounts x11fs to this directory.
`ws/` - `tofu`'s `ws` extension stores workspace contents here.
`event` - `tofu`'s event stream is stored here.
`stomach` - `tofu`'s `eat` extension represents windows in this file.

# Extensions
`tofc` supports the ability to use extensions. These extensions are called via `tofc` directly.
Extensions belong in the config's `extensions` directory. They will be integrated into the help command.
Installing an extension is as easy as copying it into the `extensions` directory.
Extensions can be executables in any language. For convenience, `tofc` will make the a wid available via the environment variable `$wid`.
Should no wid be provided in the arugments, it will default to the focused window.
Examples of extensions are provided in the [contrib](contrib) directory.

# Hooks
Rather than rules or some other mechanism of window placement, `tofu` uses hooks.
A hook is an executable that lives in the config's `hooks` directory.
When an event that matches the hook's name occurs, the hook is executed.
The hook is given the wid as the first argument, the class in a colon seperated list as the second, and the title as the third.
Example hooks may be found in the [contrib](contrib) directory.

# Desktops / monitors
On it's own, `tofu` is not aware of virtual desktops, or monitors. This functionality is up to the user to implement.
An extension, `ws` is provided to emulate virtual desktop / workspace functionality.

# Screenshots

[](demos/1.png)
