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
zstyle ':omz:plugins:*' aliases no
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'time-style' long-iso
zstyle ':omz:plugins:eza' 'hyperlink' yes
zstyle ':omz:plugins:eza' aliases yes

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
kubectl
terraform
zsh-autosuggestions
zsh-syntax-highlighting
zsh-interactive-cd
)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Aliases
alias claude='NPM_CONFIG_PREFIX=$(npm -g prefix) SRT_DEBUG=1 EDITOR=vim /usr/bin/claude'
alias cp="rsync -ah --progress"
alias dig="drill"
alias dmesg='sudo dmesg -HL'
alias grep='grep --color=auto'
alias pbpaste="wl-paste"
alias poweroff='$HOME/.dotfiles/poweroffpush.sh && sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'
alias terraform='tofu'
alias vi="nvim"
alias vim="nvim"
alias yayclean='yay -Scc'
alias yeet='yay -Rcs'

# extra zish functions
fpath=($HOME/extra_zish/ $fpath)
autoload -Uz $HOME/extra_zish/*(.:t)
