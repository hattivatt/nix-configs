#!/usr/bin/env nu
notmuch search --format=json --output=summary tag:new
  | from json
  | each { |m| notify-send $"New mail from ($m.authors)" $m.subject }
