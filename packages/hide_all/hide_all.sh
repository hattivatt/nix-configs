#!/bin/sh

get_option() {
  hyprctl getoption decoration:"$1" | awk 'NR==1{print $2}'
}

if [ "$(get_option active_opacity)" = "0.000000" ]; then
  hyprctl reload
else
  hyprctl eval " \
  hl.config({ \
    decoration = { active_opacity = 0, inactive_opacity = 0, blur = { enabled = false } } \
  })"
fi
