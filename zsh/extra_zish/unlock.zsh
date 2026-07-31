function unlock() {
    if [[ "$#" -lt 1 ]]; then
        echo "usage: unlock [host]" >&2
        return
    fi
    wait_port 2222 "${1}.i.makifun.se"
    echo "Unlocking $1"
    ssh -t -p 2222 root@${1} <<< "$(rbw get ligma-luks)"
}