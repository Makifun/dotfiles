function bofaunlock() {
    ssh -t bofaunlock <<< "$(rbw get ligma-luks)"
}
