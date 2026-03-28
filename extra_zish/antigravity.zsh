# Wrapper for Antigravity to handle cleanup and core dumps
antigravity() {
    # Generate a unique ID for this session
    local UNIT_NAME="antigravity-$(date +%s)"
    local APP_BIN="/usr/bin/antigravity"
    local TRIGGER="Lifecycle#onWillShutdown - end 'antigravityAnalytics'"

    echo "[*] Starting Antigravity as systemd unit: $UNIT_NAME"

    # 1. Run the app in a systemd scope to track all child processes.
    # We use prlimit to disable core dumps and systemd-cat to forward logs.
    systemd-run --user \
        --scope \
        --unit="$UNIT_NAME" \
        --property=KillMode=control-group \
        /bin/bash -c "exec prlimit --core=0 \"$APP_BIN\" --verbose \"\$@\" 2>&1 | systemd-cat --identifier=\"$UNIT_NAME\"" -- "$@" &

    # 2. Monitor the journal for the shutdown signal. 
    # Once detected, kill the entire control group to clean up lingering processes.
    journalctl --user --identifier="$UNIT_NAME" --follow 2>/dev/null | \
        grep --line-buffered --max-count=1 "$TRIGGER" && \
        systemctl --user kill --signal=SIGKILL "$UNIT_NAME.scope"

    echo "[*] Antigravity closed. Cleaned up remaining processes."
}
