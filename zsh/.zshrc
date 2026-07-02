# direnv
export DIRENV_WARN_TIMEOUT=1m

# node
export NODE_OPTIONS="--no-deprecation"

# Appleshit checker
if [[ "$(uname)" == "Darwin" ]]; then
  # fix aws cli ssl error shit
  export AWS_CA_BUNDLE=/opt/homebrew/etc/openssl@3/cert.pem
  # password-manager.zsh
  source ${XDG_CONFIG_HOME:-$HOME/.config/}zsh/password-manager.zsh
  # path
  export PATH="$HOME/bin:$PATH:."
  export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  # alias
  alias vpn-c='ps aux | grep openconnect | grep -v grep | wc -l'
elif [[ "$(uname)" == "Linux" ]]; then
  # path
  export PATH="${PATH}:$HOME/bin"
  export PATH="${PATH}:$HOME/go/bin"
  # alias
  alias claude='NPM_CONFIG_PREFIX=$(npm -g prefix) SRT_DEBUG=1 EDITOR=vim /usr/bin/claude'
  alias dig="drill"
  alias dmesg='sudo dmesg -HL --ctime'
  alias pbpaste="wl-paste"
  alias poweroff='$HOME/.dotfiles/poweroffpush/poweroffpush.sh && sudo systemctl poweroff'
  alias reboot='sudo systemctl reboot'
  alias watch='hwatch -d line --border'
fi

# Common aliases
alias cp="rsync -ah --progress"
alias grep='grep --color=auto'
alias terraform='tofu'
alias vi="nvim"
alias vim="nvim"

# k8s
# kubectl krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Extra tweaks
export COLORTERM=truecolor
export MANPAGER="bat -plman"
export PAGER="bat"

# History
HISTSIZE=500000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# zstyling
zstyle ':omz:plugins:*' aliases no
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'time-style' long-iso
zstyle ':omz:plugins:eza' 'hyperlink' yes
zstyle ':omz:plugins:eza' aliases yes
zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts \
  $(grep -rhE '^Host ' ~/.ssh/config.d 2>/dev/null \
    | awk '{for (i=2; i<=NF; i++) print $i}' \
    | grep -vE '[*?]' \
    | sort -u)
zstyle ':omz:plugins:kubectl' aliases yes

# p10k + Oh My Zsh + Plugins
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH="$HOME/.oh-my-zsh"
plugins=(
brew
command-not-found
direnv
extract
eza
fzf
fzf-tab
genpass
kate
kubectl
ssh
terraform
zsh-autosuggestions
zsh-syntax-highlighting
zsh-interactive-cd
)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# extra zish functions
for file in $HOME/extra_zish/*.zsh; do
  source "$file"
done

# p10k gitstatus disablement
typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true

# LM Studio
if [ -d "$HOME/.lmstudio/bin" ]; then
  export PATH="$PATH:$HOME/.lmstudio/bin"
fi