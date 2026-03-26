#!/bin/sh

/usr/bin/git --git-dir=$HOME/dotfiles/.git --work-tree=$HOME/dotfiles/ add .*
/usr/bin/git --git-dir=$HOME/dotfiles/.git --work-tree=$HOME/dotfiles/ add *
/usr/bin/git --git-dir=$HOME/dotfiles/.git --work-tree=$HOME/dotfiles/ commit -m "$(date)"
/usr/bin/git --git-dir=$HOME/dotfiles/.git --work-tree=$HOME/dotfiles/ push