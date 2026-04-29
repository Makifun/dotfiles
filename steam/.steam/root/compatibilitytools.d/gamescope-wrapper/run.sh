#!/bin/bash
# $1 is the verb (waitforexitandrun, run, etc.)
VERB="$1"
shift

# arRPC socket fixes for Wine/Proton Discord rich presence
for i in {0..9}; do
  SOCKET="/run/user/$(id -u)/discord-ipc-$i"
  if [[ -S "$SOCKET" ]]; then
    ln -sf "$SOCKET" "/tmp/discord-ipc-$i" 2>/dev/null
  fi
done
export PRESSURE_VESSEL_SHARE_HOME=1

# Proton GE Custom path(arch) + NTSYNC
export PROTON_USE_NTSYNC=1
export PROTON_LOCAL_SHADER_CACHE=1
export PROTON_NO_WM_DECORATION=1
export PROTON_ENABLE_WAYLAND=1
PROTON_GE_PATH="/usr/share/steam/compatibilitytools.d/proton-ge-custom"

# Games to disable gamescope for
DISABLE_GAMESCOPE_APPIDS=(
  "1245620" # Elden Ring
  "730"     # CS2
)

for appid in "${DISABLE_GAMESCOPE_APPIDS[@]}"; do
  if [[ "$STEAM_COMPAT_APP_ID" == "$appid" ]]; then
    echo "[gamescope-wrapper] Skipping gamescope for AppID: $appid"
    exec "$PROTON_GE_PATH/proton" "$VERB" "$@"
  fi
done

# Only wrap launch verbs — install/uninstall/etc. must run bare or Steam hangs
if [[ "$VERB" == "waitforexitandrun" || "$VERB" == "run" ]]; then
  exec gamescope -W 3440 -H 1440 -r 175 --force-grab-cursor -f -- \
    "$PROTON_GE_PATH/proton" "$VERB" "$@"
else
  exec "$PROTON_GE_PATH/proton" "$VERB" "$@"
fi

