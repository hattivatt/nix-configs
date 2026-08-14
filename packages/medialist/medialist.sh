#!/usr/bin/env bash

#saving find results to array
readarray -t F_ARRAY <<< "$(find ~/Downloads/MoviesAndShows -type f -regex '\(.*.mkv\|.*.avi\)')"

declare -A MEDIA

# Add elements to MEDIA array
get_media() {

if [[ ${#F_ARRAY[@]} -gt 0 ]]; then
  for i in "${!F_ARRAY[@]}"; do
    path=${F_ARRAY[$i]}
    file=$(basename "${F_ARRAY[$i]}")
    MEDIA+=(["$file"]="$path")
  done
  else
      echo "$HOME/Downloads is empty!"
      echo "Please put something in it."
      echo "Only video files are accepted."
      exit 1
  fi


}

gen_list(){
  for i in "${!MEDIA[@]}"
  do
    echo "$i"
  done
}

main() {
  get_media
  media=$( (gen_list) | fuzzel -d --placeholder "Media > " --anchor=top-right -w 70 -l 25 --match-mode=fuzzy)

  if [ -n "$media" ]; then
    mpv "${MEDIA[$media]}"
  fi
}

main

exit 0
