#!/usr/bin/env zsh

pi() {
  local git_bind=()
  [ -d "$PWD/.git" ] && git_bind=(--ro-bind "$PWD/.git" "$PWD/.git")
  bwrap \
    --ro-bind /usr /usr \
    --ro-bind /bin /bin \
    --ro-bind /lib /lib \
    --ro-bind /lib64 /lib64 \
    --proc /proc \
    --tmpfs /tmp \
    --dir /home \
    --bind "$PWD" "$PWD" \
    "${git_bind[@]}" \
    --bind "$HOME/.pi" "$HOME/.pi" \
    --setenv PATH "/home/makifun/.nix-profile/bin:/usr/bin:/bin" \
    -- pi "$@"
}