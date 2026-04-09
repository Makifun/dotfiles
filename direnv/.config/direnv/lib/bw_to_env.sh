#!/usr/bin/env bash

rbw_export_folder() {
  if [[ "$#" -lt 1 ]]; then
    echo "You must specify a folder" >&2
    return
  fi

  local folder=$1
  echo "🔍 Exporting secrets from folder: $folder"

  local existing_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)
  while read -r folder name id; do
    export "$name=$(rbw get "$id")"
    echo "✅️ Exported $name"
  done < <(rbw list --fields folder --fields name --fields id 2>/dev/null | grep "^${folder}")

  # Kill only the NEW rbw-agent for this profile
  local current_agents=$(pgrep -f "rbw-agent" 2>/dev/null || true)
  for pid in $current_agents; do
    if [[ ! "$existing_agents" =~ $pid ]]; then
      kill "$pid" 2>/dev/null || true
      echo "🔒 Locked the vault again (rbw-agent $pid stopped)"
    fi
  done
}
