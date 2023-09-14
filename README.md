This script can be used to send an arbitrary string to the terminal clipboard using the OSC 52 escape sequence

See: http://invisible-island.net/xterm/ctlseqs/ctlseqs.html , section "Operating System Controls", Ps => 52.



Note for tmux 3.3 or higher users:

Starting from tmux 3.3, the passthrough escape sequence is now controlled by the 'allow-passthrough' option.
By default, this option is set to off, which will make this plugin ineffective. To enable the plugin,
please add `set -g allow-passthrough on` to your tmux configuration file.

See: https://is.gd/ZoO5SX
