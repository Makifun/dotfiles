function antigravityfix() {
    # Wrapper for Antigravity to handle cleanup and core dumps

    # Generate a unique ID for this session
    local UNIT_NAME="antigravity-$(date +%s)"
    local APP_BIN="/opt/antigravity-ide/bin/antigravity-ide"
    local TRIGGER="Lifecycle#onWillShutdown - end 'antigravityAnalytics'"

    echo "[*] Starting Antigravity as systemd unit: $UNIT_NAME"

    systemd-run --user \
        --scope \
        --unit="$UNIT_NAME" \
        --property=KillMode=control-group \
        /bin/bash -c "exec prlimit --core=0 \"$APP_BIN\" --verbose \"\$@\" 2>&1 | systemd-cat --identifier=\"$UNIT_NAME\"" -- "$@" &

    journalctl --user --identifier="$UNIT_NAME" --follow 2>/dev/null | \
        grep --line-buffered --max-count=1 "$TRIGGER" && \
        systemctl --user kill --signal=SIGKILL "$UNIT_NAME.scope"

    echo "[*] Antigravity closed. Cleaned up remaining processes."
}