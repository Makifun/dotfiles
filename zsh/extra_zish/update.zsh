function update() {
    local makizen="/mnt/870evo2tb1/git/makizen/apply.sh"
    local -a failed

    # Run one update step and remember failures so later steps still run
    _update_step() {
        local name="$1"; shift
        print -P "\n%F{blue}==> ${name}%f"
        "$@" || failed+=("$name")
    }

    _update_step "System (paru)" paru -Syu

    if command -v flatpak &> /dev/null; then
        _update_step "Flatpak" flatpak update -y
        _update_step "Flatpak cleanup" flatpak uninstall --unused -y
    fi

    if [[ -x "$makizen" ]]; then
        _update_step "makizen" "$makizen"
    fi

    if typeset -f omz &> /dev/null; then
        _update_step "oh-my-zsh" omz update
    fi

    if command -v tldr &> /dev/null; then
        _update_step "tldr cache" tldr --update
    fi

    unfunction _update_step

    # Config files that pacman did not overwrite need a manual merge
    if command -v pacdiff &> /dev/null; then
        local pacnew
        pacnew=$(pacdiff -o 2> /dev/null) && [[ -n "$pacnew" ]] && print -P "\n%F{yellow}Unmerged .pacnew files:%f\n$pacnew"
    fi

    # Arch removes the modules of the old kernel, so a missing directory means a new kernel
    if [[ ! -d "/usr/lib/modules/$(uname -r)" ]]; then
        print -P "\n%F{yellow}Kernel updated: reboot required.%f"
    fi

    if (( ${#failed} )); then
        print -P "\n%F{red}Failed steps: ${(j:, :)failed}%f"
        return 1
    fi
    print -P "\n%F{green}All updates done.%f"
}
