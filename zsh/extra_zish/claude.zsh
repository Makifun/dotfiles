#!/usr/bin/env zsh

# claude-sandbox.zsh — External bubblewrap jail for Claude Code (zsh function)
#
# Belt-and-suspenders approach: wraps Claude Code in an OS-level
# sandbox OUTSIDE of Claude's own built-in sandbox.
#
# Policy:
#   - Network: fully open (no restrictions)
#   - Filesystem: project dir + explicit config paths only
#   - Environment: cleared; only an explicit allowlist is passed in
#   - Everything else: invisible or read-only
#
# Usage:
#   claude-sandbox                                     # current dir
#   claude-sandbox /path/to/project                    # specific project
#   claude-sandbox /path/to/project --print "do thing" # pass args to claude

claude-sandbox() {
    # Local option scope: nothing here leaks into your interactive shell.
    emulate -L zsh
    setopt err_return pipe_fail

    # NOTE: never use `path` as a variable name in zsh — it's tied to $PATH.
    local p project_dir claude_bin kube_src

    # ── Configuration ──────────────────────────────────────────────
    if [[ -n ${1:-} && -d $1 ]]; then
        project_dir=${1:A}   # absolute, symlinks resolved (like realpath)
        shift
    else
        project_dir=$PWD
    fi

    # Paths Claude gets read-write access to
    local -a rw_paths=(
        $project_dir
        $HOME/.claude
        $HOME/.claude.json
    )

    # Paths Claude gets read-only access to
    local -a ro_paths=(
        /usr /lib /lib64 /etc /bin /sbin /opt
        $HOME/.config/gh
        $HOME/.gitconfig
        $HOME/.ssh/config
        $HOME/.ssh/id_ed25519_only_git
        $HOME/.ssh/id_ed25519_only_git.pub
        $HOME/.ssh/known_hosts
    )

    # Paths explicitly denied (masked with an empty tmpfs)
    local -a deny_paths=(
        $HOME/.gnupg/private-keys-v1.d
    )

    # ── Preflight checks ──────────────────────────────────────────
    if (( ! $+commands[bwrap] )); then
        print -u2 "ERROR: bubblewrap not installed."
        print -u2 "  Arch BTW: paru -S bubblewrap"
        return 1
    fi

    if (( ! $+commands[claude] )); then
        print -u2 "ERROR: claude not found in PATH."
        print -u2 "  Arch BTW: paru -S claude-code"
        return 1
    fi

    # Resolve claude binary through symlinks (like readlink -f)
    claude_bin=${commands[claude]:A}

    # ── Secrets ───────────────────────────────────────────────────
    # These are fed to bwrap over a file descriptor (--args), NOT on the
    # command line, so they never show up in /proc/<pid>/cmdline.
    local -a secret_args

    local gh_token_file=$HOME/.config/gh-sandbox-token
    if [[ -f $gh_token_file && -r $gh_token_file ]]; then
        local gh_token=$(<$gh_token_file)   # trailing newline stripped
        if [[ -n $gh_token ]]; then
            secret_args+=(--setenv GH_TOKEN $gh_token)
            print -u2 "Passing GitHub token from \$HOME/.config/gh-sandbox-token into the sandbox."
        fi
    fi

    # ── Kubeconfig ────────────────────────────────────────────────
    # Mounted at the default location so kubectl finds it without KUBECONFIG.
    if [[ -f $HOME/.kube/claude-sandbox-config ]]; then
        kube_src=$HOME/.kube/claude-sandbox-config
        print -u2 "Mounting sandbox kubeconfig ($kube_src) read-only into the sandbox."
    elif [[ -f $HOME/.kube/config ]]; then
        kube_src=$HOME/.kube/config
        print -u2 "Mounting kubeconfig ($kube_src) read-only into the sandbox."
        print -u2 "Warning: no ~/.kube/claude-sandbox-config found — falling back to the OIDC-based kubeconfig, which cannot authenticate headlessly in the sandbox."
    fi

    # ── Build bwrap arguments ─────────────────────────────────────
    local -a args

    # Wipe the inherited host environment. Must come first: bwrap applies
    # --clearenv/--setenv in order, so every --setenv below survives it.
    args+=(--clearenv)

    # Process isolation
    args+=(--unshare-pid --die-with-parent)

    # Network intentionally NOT unshared. To lock it down:
    # args+=(--unshare-net)

    # Essential virtual filesystems
    args+=(--proc /proc)
    args+=(--dev /dev)
    args+=(--tmpfs /run)

    # Read-only system mounts (non-home)
    for p in $ro_paths; do
        [[ -e $p && $p != $HOME(|/*) ]] && args+=(--ro-bind $p $p)
    done

    # Private /tmp
    args+=(--tmpfs /tmp)

    # Read-write mounts (non-home)
    for p in $rw_paths; do
        [[ -e $p && $p != $HOME(|/*) ]] && args+=(--bind $p $p)
    done

    # Empty tmpfs $HOME — MUST precede all home-relative binds
    args+=(--tmpfs $HOME)

    # Read-only home-relative paths on top of tmpfs home
    for p in $ro_paths; do
        [[ -e $p && $p == $HOME/* ]] && args+=(--ro-bind $p $p)
    done

    # Read-write home-relative paths on top of tmpfs home
    for p in $rw_paths; do
        [[ -e $p && $p == $HOME/* ]] && args+=(--bind $p $p)
    done

    # Kubeconfig (after the tmpfs home, or it would be wiped)
    [[ -n $kube_src ]] && args+=(--ro-bind $kube_src $HOME/.kube/config)

    # Bind project dir again last (covers the case where it's $HOME-relative
    # and got shadowed, or lives outside $HOME)
    args+=(--bind $project_dir $project_dir)

    # Mask sensitive paths on top of everything
    for p in $deny_paths; do
        [[ -e $p ]] && args+=(--tmpfs $p)
    done

    args+=(--chdir $project_dir)

    # ── Environment allowlist ─────────────────────────────────────
    args+=(--setenv HOME    $HOME)
    args+=(--setenv USER    ${USER:-$(whoami)})
    args+=(--setenv LOGNAME ${USER:-$(whoami)})
    args+=(--setenv PATH    /usr/local/bin:/usr/bin)
    args+=(--setenv TERM    ${TERM:-xterm-256color})
    args+=(--setenv LANG    ${LANG:-en_US.UTF-8})
    args+=(--setenv SHELL   /bin/bash)
    [[ -n ${COLORTERM:-} ]] && args+=(--setenv COLORTERM $COLORTERM)

    # ── Summary ────────────────────────────────────────────────────
    print "╔══════════════════════════════════════════════════════╗"
    print "║  Claude Code — External Bubblewrap Sandbox           ║"
    print "╠══════════════════════════════════════════════════════╣"
    print "║  Project:  ${project_dir:t}"
    print "║  Network:  OPEN (no restrictions)"
    print "║  Env:      cleared (allowlist only)"
    print "║  FS Write: project + ~/.claude"
    print "║  /tmp:     private tmpfs (not shared with host)"
    print "║  FS Read:  system, gh, git, ssh (git key), kube"
    print "╚══════════════════════════════════════════════════════╝"
    print

    # ── Launch ─────────────────────────────────────────────────────
    # No `exec` here: in a function, exec would replace your interactive shell.
    if (( $#secret_args )); then
        # --args 3 reads NUL-separated extra args from fd 3. It comes after
        # --clearenv (inside $args), so the secret --setenv isn't wiped.
        bwrap $args --args 3 $claude_bin --dangerously-skip-permissions "$@" \
            3< <(print -rN -- $secret_args)
    else
        bwrap $args $claude_bin --dangerously-skip-permissions "$@"
    fi
}