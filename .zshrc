# dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# direnv
export DIRENV_WARN_TIMEOUT=1m

# PATH additions
export PATH="${PATH}:$HOME/bin"
export PATH="${PATH}:$HOME/go/bin"

# node
export NODE_OPTIONS="--no-deprecation"

# History
HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# zstyling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'time-style' long-iso
zstyle ':omz:plugins:eza' 'hyperlink' yes

# p10k + Oh My Zsh + Plugins
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH="$HOME/.oh-my-zsh"
plugins=(
command-not-found
direnv
extract
eza
fzf
fzf-tab
kate
zsh-autosuggestions
zsh-syntax-highlighting
zsh-interactive-cd
)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Skip all plugin aliases
zstyle ':omz:plugins:*' aliases no

# Aliases
alias vim="nvim"
alias vi="nvim"
alias cp="rsync -ah --progress"
alias dig="drill"
alias yeet='yay -Rcs'
alias yayclean='yay -Scc'
alias cat='bat'
alias grep='grep --color=auto'
alias reboot='sudo systemctl reboot'
alias poweroff='$HOME/git/makizen/poweroffpush.sh && sudo systemctl poweroff'
alias dmesg='sudo dmesg -HL'
alias pbpaste="copyq clipboard"
alias claude='NPM_CONFIG_PREFIX=$(npm -g prefix) SRT_DEBUG=1 EDITOR=vim /usr/bin/claude'

# k8s
source <(kubectl completion zsh)
alias k=kubectl
complete -o default -F __start_kubectl k

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
