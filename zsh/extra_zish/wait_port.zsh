function wait_port() {
    if [[ "$#" -lt 1 ]]; then
        echo "usage: wait_port <port> [host]" >&2
        return
    fi
    local PORT="$1"
    local HOST="$2"
    echo "Waiting for $PORT on $HOST..."
    until nc -z -w 2 "$HOST" "$PORT" 2>/dev/null; do sleep 2; done
    echo "$HOST:$PORT is online"
}