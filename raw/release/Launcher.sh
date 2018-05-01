#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

GZDOOMBIN="gzdoom"
unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*)
        GZDOOMINI="$HOME/Library/Preferences/gzdoom.ini"
        GZDOOMBIN="$SCRIPTPATH/GZDoom.app/Contents/MacOS/gzdoom"
        ;;
    Linux*)
        GZDOOMINI="$HOME/.config/gzdoom/gzdoom.ini"
        ;;
    *)
        echo "Warning: Unable to detect OS from uname:${unameOut}"
        GZDOOMINI=''
esac

launch() {
    echo "Using IWAD at $IWAD"
    nohup "$GZDOOMBIN" -iwad "$IWAD" -file "$SCRIPTPATH/imps_r_us.pk3"
}

echo "Looking for DOOM.WAD in common locations..."
WADSEARCHPATH="$SCRIPTPATH/DOOM.WAD"
if [ -f "$WADSEARCHPATH" ]; then
    IWAD="$WADSEARCHPATH"
    launch
    exit 0
fi

set +o nounset
WADSEARCHPATH="$DOOMWADDIR/DOOM.WAD"
if [ -f "$WADSEARCHPATH" ]; then
    IWAD="$WADSEARCHPATH"
    launch
    exit 0
fi
set -o nounset

if [ -f "$GZDOOMINI" ]; then
    echo "Trying to look for WADs specified in gzdoom.ini path"
    awk '/^\[IWADSearch.Directories\]/{flag=1;next}/^\[/{flag=0}flag' ~/Library/Preferences/gzdoom.ini|grep '^Path='|fgrep -v '$PROGDIR'|fgrep -v '$DOOMWADDIR'|sort|uniq|cut -d'=' -f2|while read GZSEARCHPATH; do
        GZWADPATH="$GZSEARCHPATH/DOOM.WAD"
        if [ -f "$GZWADPATH" ]; then
            IWAD="$GZWADPATH"
            launch
            exit 1 # This do is actually running in a subshell so we have to signal to the outer script to stop
        fi
        if [[ "$?" != 0 ]]; then
            exit 0
        fi
    done
fi

echo
echo "We highly reccomend playing with DOOM.WAD but were unable to find it. If you own DOOM, please drop a copy of DOOM.WAD into '$SCRIPTPATH' and run the launcher again."
sleep 2
echo "Falling back to Freedoom..."
sleep 1

IWAD="$SCRIPTPATH/freedoom1.wad"
launch
