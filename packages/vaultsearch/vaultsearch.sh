#!/bin/bash

set -e

picker="fzf"
if [ "${1:-}" = "--fuzzel" ]; then
  picker="fuzzel"
fi

pick() {
  if [ "$picker" = "fuzzel" ]; then
    fuzzel --dmenu --lines=20 --prompt="${1}: "
  else
    fzf --prompt="${1}: "
  fi
}

if vault token lookup &> /dev/null ; then
  secpath=$(vault secrets list | awk '{ print $1 }' | tail -n +3 | pick "path")

  while true ; do
    secpath=${secpath}$(vault kv list "${secpath}" | tail -n +3 | pick "path")
    if [ "${secpath: -1}" != "/" ]; then
      break
    fi
  done

  secret=$(vault kv get -format=json "${secpath}")
  key=$(printf '%s' "${secret}" | jq -r '.data.data | keys[]' | pick "key")

  printf '%s' "${secret}" | jq -r --arg key "${key}" '.data.data[$key]' | wl-copy
else
  echo "Not logged in to vault"
  exit 2
fi
