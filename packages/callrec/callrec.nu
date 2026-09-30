#!/usr/bin/env nu

# Запись звука в Opus: то, что слышишь ты (выбранное приложение или устройство
# вывода), и твой микрофон попадают в один файл. Для разговоров, в которых участвуешь.
# Источник по умолчанию выбирается интерактивно через fzf, микрофон - дефолтный вход.
# Прервать: Ctrl+C (файл закроется корректно).

const MIX_NODE = "rec-mix"

def all-nodes [] {
  pw-dump | from json
  | where {|n| $n.type == "PipeWire:Interface:Node" }
  | each {|n|
      let p = ($n.info? | get -o props? | default {})
      {id: $n.id
       name: ($p | get -o "node.name"? | default "")
       class: ($p | get -o "media.class"? | default "")
       desc: ($p | get -o "node.description"? | default "")
       app: ($p | get -o "application.name"? | default "")}
    }
}

def sources [] {
  all-nodes
  | where {|n| $n.class in ["Stream/Output/Audio" "Audio/Sink"] }
  | where {|n| not ($n.name =~ '^rec-mix$|^mix-|^pw-record$') }
  | each {|n|
      let shown = (if $n.class == "Stream/Output/Audio" {
          if $n.app == "" { $n.name } else { $n.app }
        } else {
          if $n.desc == "" { $n.name } else { $n.desc }
        })
      let kind = (if $n.class == "Stream/Output/Audio" { "app" } else { "dev" })
      {label: $"($kind): ($shown)", name: $n.name, class: $n.class}
    }
}

def inputs [] {
  all-nodes
  | where {|n| $n.class == "Audio/Source" }
  | each {|n|
      let shown = (if $n.desc == "" { $n.name } else { $n.desc })
      {label: $"mic: ($shown)", name: $n.name}
    }
}

def find-node [pattern class] {
  let found = (all-nodes | where {|n| $n.class == $class } | where {|n| $n.name =~ $pattern })
  if ($found | is-empty) { null } else { $found | first }
}

def pick [rows prompt] {
  if ($rows | is-empty) { return null }
  let lines = ($rows | each {|r| $"($r.name)(char tab)($r.label)" } | str join (char nl))
  let sel = ($lines | ^fzf --delimiter "\t" "--with-nth=2.." --prompt $prompt --height 40% --reverse e> /dev/null | str trim)
  if $sel == "" { null } else { $sel | split row (char tab) | first }
}

def resolve [rows spec] {
  let exact = ($rows | where {|r| $r.name == $spec })
  if ($exact | length) == 1 { return ($exact | first) }
  let by_name = ($rows | where {|r| $r.name =~ $spec })
  if ($by_name | length) == 1 { return ($by_name | first) }
  let by_label = ($rows | where {|r| $r.label =~ $spec })
  if ($by_label | length) == 1 { return ($by_label | first) }
  let hits = (if ($by_name | is-empty) { $by_label } else { $by_name })
  if ($hits | is-empty) { print $"не найдено: ($spec)"; exit 1 }
  print $"неоднозначно: ($spec) → (($hits | get name) | str join ', ')"
  exit 1
}

def cleanup [sink_id] {
  # убить фоновые loopback-процессы, если живы (pkill вернёт 1, если их нет — это норма)
  try { ^pkill -f "pw-loopback.*mix-" o+e> /dev/null }
  # уничтожить виртуальный приёмник, если создался
  if ($sink_id != null) {
    try { ^pw-cli destroy $sink_id o+e> /dev/null }
  } else {
    # подчистить оставшийся с прошлого раза
    let stale = (find-node "^rec-mix$" "Audio/Sink")
    if $stale != null { try { ^pw-cli destroy $stale.id o+e> /dev/null } }
  }
}

def main [
  outdir?: path          # папка для записи (по умолчанию текущая)
  --output (-o): string  # источник неинтерактивно: имя ноды или подстрока
  --input: string        # микрофон неинтерактивно (по умолчанию дефолтный вход)
  --select-input (-i)    # выбрать микрофон интерактивно
  --list (-l)            # показать доступные источники и входы и выйти
] {
  let outdir = ($outdir | default ".")
  let outs = (sources)
  let ins = (inputs)

  if $list {
    print "источники (приложения и устройства вывода):"
    for r in $outs { print $"  ($r.name)  —  ($r.label)" }
    print ""
    print "входы (микрофоны):"
    for r in $ins { print $"  ($r.name)  —  ($r.label)" }
    return
  }

  let out = (if $output != null { resolve $outs $output } else {
      let p = (pick $outs "источник > ")
      if $p == null { print "выбор отменён"; exit 1 }
      ($outs | where {|r| $r.name == $p } | first)
    })

  let mic = (if $input != null {
      (resolve $ins $input) | get name
    } else if $select_input {
      let p = (pick $ins "микрофон > ")
      if $p == null { print "выбор отменён"; exit 1 }
      $p
    } else { null })

  # --- зачистить возможный мусор от прерванного прошлого запуска
  cleanup null

  let mic_label = (if $mic == null { "дефолтный вход" } else { $mic })
  print $"источник: ($out.label)  [($out.name)]"
  print $"микрофон: ($mic_label)"

  let ts = (date now | format date "%Y%m%d-%H%M%S")
  let out_file = ($outdir | path join $"rec-($ts).opus")

  ^pw-cli create-node adapter "{ factory.name=support.null-audio-sink node.name=rec-mix media.class=Audio/Sink object.linger=true }" o+e> /dev/null

  let sink = (find-node "^rec-mix$" "Audio/Sink")
  if $sink == null {
    print "не удалось создать виртуальный микшер"
    exit 1
  }
  let sink_id = $sink.id

  # у устройства вывода берём монитор, у приложения — его исходящий стрим
  if $out.class == "Audio/Sink" {
    job spawn { ^pw-loopback --name mix-src --capture $out.name -i "{ stream.capture.sink=true }" --playback $MIX_NODE o+e> /dev/null }
  } else {
    job spawn { ^pw-loopback --name mix-src --capture $out.name --playback $MIX_NODE o+e> /dev/null }
  }

  if $mic == null {
    job spawn { ^pw-loopback --name mix-mic --playback $MIX_NODE o+e> /dev/null }
  } else {
    job spawn { ^pw-loopback --name mix-mic --capture $mic --playback $MIX_NODE o+e> /dev/null }
  }

  print $"запись: ($out_file) — остановить Ctrl+C"
  try {
    ^pw-record --target $MIX_NODE -P "{ stream.capture.sink=true }" $out_file
  } catch { } # прервано пользователем — просто переходим к уборке

  cleanup $sink_id
  print $"done: ($out_file)"
}
