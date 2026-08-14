#!/usr/bin/env nu

let now = (date now | format date "%Y-%m-%dT%H:%M:00%z" | into datetime)

let win_start = ($now + 10min)
let win_end   = ($now + 11min)

let fmt = "{start-long}|{title}"

# complete перехватывает stdout/stderr/exit_code, скрипт не разъебётся на warning'ах khal
let result = (^khal list --format $fmt now 12m | complete)

if $result.exit_code != 0 {
    # Раскомментируй для отладки:
    # print -e $"khal error: ($result.stderr)"
    return
}

let events = (
    $result.stdout
    | lines
    | where {|l| ($l | str contains "|") and (not ($l | str trim | is-empty)) }
    | each {|line|
        let parts = ($line | split row "|" | str trim)
        if ($parts | length) < 2 { return null }

        let start = (try { $parts.0 | into datetime } catch { return null })
        let title = ($parts | skip 1 | str join "|")

        if $start >= $win_start and $start < $win_end {
            { start: $start, title: $title }
        } else {
            null
        }
    }
    | compact
)

for event in $events {
    let tag  = $"khal-($event.start | format date "%Y%m%d%H%M")"
    let body = $"($event.title)\nBaşlangıç: ($event.start | format date "%H:%M")"

    ^notify-send -h string:x-dunst-stack-tag:($tag) "⏰ Yakında etkinlik" $body
}
