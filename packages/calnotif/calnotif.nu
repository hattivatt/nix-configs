#!/usr/bin/env nu

# khal делает setlocale(LC_ALL, "") и рендерит даты через локаль сессии:
# при ru_RU {start-long} выдаёт "Ср 26 авг 2026 15:30:00", который nushell
# не парсит -> события молча превращаются в null и нотификации не уходят.
# Поэтому: принудительная C-локаль + чисто числовые поля (%x = %m/%d/%y,
# %X = %H:%M:%S), datetime собираем руками.
let now = (date now | format date "%Y-%m-%dT%H:%M:00%z" | into datetime)

let win_start = ($now + 10min)
let win_end   = ($now + 11min)

# только цифры, никакой локалезависимой словесщины
let fmt = "{start-date-long}|{start-time}|{title}"

# complete перехватывает stdout/stderr/exit_code, скрипт не разъебётся на warning'ах khal
let result = (with-env { LC_ALL: "C" } { ^khal list --format $fmt now 12m } | complete)

if $result.exit_code != 0 {
    # Раскомментируй для отладки:
    # print -e $"khal error: ($result.stderr)"
    return
}

let win_start_ts = ($win_start | format date "%s" | into int)
let win_end_ts   = ($win_end   | format date "%s" | into int)

let events = (
    $result.stdout
    | lines
    | where {|l| ($l | str contains "|") and (not ($l | str trim | is-empty)) }
    | each {|line|
        let parts = ($line | split row "|" | str trim)
        if ($parts | length) < 3 { return null }
        if ($parts.0 !~ '^\d\d/\d\d/\d\d$') { return null }
        if ($parts.1 !~ '^\d\d:\d\d:\d\d$') { return null }

        let dp = ($parts.0 | split row "/")
        let start = (try { $"20($dp.2)-($dp.0)-($dp.1)T($parts.1)" | into datetime } catch { return null })
        let title = ($parts | skip 2 | str join "|")
        let ts = ($start | format date "%s" | into int)

        if $ts >= $win_start_ts and $ts < $win_end_ts {
            { start: $start, title: $title }
        } else {
            null
        }
    }
    | compact
)

for event in $events {
    let tag  = $"khal-(($event.start | format date "%Y%m%d%H%M"))"
    let body = $"($event.title)\nBaşlangıç: ($event.start | format date "%H:%M")"

    ^notify-send -h string:x-dunst-stack-tag:($tag) "⏰ Yakında etkinlik" $body
}
