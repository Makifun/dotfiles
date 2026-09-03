#!/usr/bin/env bash

rbw_export_folder() {
  if [[ "$#" -lt 1 ]]; then
    echo "You must specify at least one folder" >&2
    return 1
  fi

  echo "🔍 Exporting secrets from: $*"

  local existing_agents
  existing_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)

  local list_output
  if ! list_output=$(rbw list --fields folder --fields name --fields id 2>&1); then
    echo "❌ rbw list failed:" >&2
    echo "$list_output" >&2
    return 1
  fi

  local folder item_folder item_name item_id secret exported=0
  for folder in "$@"; do
    while IFS=$'\t' read -r item_folder item_name item_id; do
      [[ -z "$item_id" ]] && continue
      if ! secret=$(rbw get "$item_id" 2>&1); then
        echo "❌ Failed to decrypt $item_name: $secret" >&2
        continue
      fi
      export "$item_name=$secret"
      echo "✅️ Exported $item_name"
      exported=$((exported + 1))
    done < <(printf '%s\n' "$list_output" | grep "^${folder}"$'\t')
  done

  if [[ "$exported" -eq 0 ]]; then
    echo "⚠️  No secrets exported for: $* (check the folder name in rbw, and that the vault actually unlocked)" >&2
  fi

  # Kill only the NEW rbw-agent for this profile
  local current_agents pid
  current_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)
  for pid in $current_agents; do
    if [[ ! "$existing_agents" =~ $pid ]]; then
      kill "$pid" 2>/dev/null || true
      echo "🔒 Locked the vault again (rbw-agent $pid stopped)"
    fi
  done
}
