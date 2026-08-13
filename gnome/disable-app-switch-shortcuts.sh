#!/bin/bash
#
# Disables GNOME's Alt+1..9 "switch to application" shortcuts
# (org.gnome.shell.keybindings switch-to-application-N), which launch/switch
# to the Nth app pinned in the Dash favorites (e.g. Alt+3 -> Spotify).
#
# These steal Alt+<digit> from apps that use it for their own shortcuts
# (e.g. KiCad's Alt+1/2/3 for top/front/3D view). Since app launching is
# handled by ulauncher (Super+space) instead, this frees the Alt+<digit>
# range entirely rather than just moving it to another key.
#
# Idempotent; safe to re-run.

set -e

if ! command -v gsettings >/dev/null 2>&1; then
    echo "gsettings not found (not a GNOME session) — skipping."
    exit 0
fi

for i in 1 2 3 4 5 6 7 8 9; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done

echo "Disabled GNOME switch-to-application-1..9 (Alt+1..9 app-launch shortcuts)."
