#!/usr/bin/env zsh

function kn() {
  ctx=`kubectl config current-context`
  ns=$1

  # verify that the namespace exists
  ns=`kubectl get namespace $1 --no-headers --output=go-template={{.metadata.name}} 2>/dev/null`
  if [ -z "${ns}" ]; then
    echo "Namespace (${1}) not found, using default"
    ns="default"
  fi

  kubectl config set-context ${ctx} --namespace="${ns}"
}

function kcc() {
  ctx=$(kubectl config get-contexts -o name | fzf)
  # verify that the namespace exists
  kubectl config use-context ${ctx}
}

function kg() {
  name=$1
  kubectl get po -l name="$name" 2>/dev/null
  kubectl get po -l app.kubernetes.io/name="$name" 2>/dev/null
}

alias WP='watch -t "kubectl get pod"'
alias -g PODIMAGE=' -o jsonpath="{.spec.containers[*].image}"'
alias -g PODIMAGES=' -o jsonpath="{.items[*].spec.containers[*].image}"'
alias -g LABELS=" -o json | jq -r 'reduce .items[].metadata.labels as \$item ({}; . + \$item)'"
alias -g PORTS=' -o jsonpath="{.spec.containers[*].ports}"'
alias -g Y=" -o yaml | batcat -l yaml"
alias -g SECRET='-o json | jq -r ".data | to_entries[] | .value" | base64 -d'

Diff() {
  app=$1
  argocd app diff $app | bat -l Diff
}

pods() {
  FZF_DEFAULT_COMMAND="kubectl get pods --all-namespaces" \
    fzf --info=inline --layout=reverse --header-lines=1 \
    --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
    --header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
    --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
    --bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash > /dev/tty' \
    --bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty' \
    --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
    --preview-window up:follow \
    --preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
}

kl() {
  kubectl get --show-kind --ignore-not-found $(kubectl api-resources --verbs=list --namespaced --cached=true -o name |
    paste -s -d, -)
}

kla() {
  kubectl get --show-kind --ignore-not-found $(kubectl api-resources --verbs=list --namespaced=false --cached=true -o name |
    paste -s -d, -)
}
