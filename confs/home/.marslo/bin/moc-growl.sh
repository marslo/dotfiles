#!/usr/bin/env bash

while out=$(/usr/local/Cellar/moc/2.5.2_2/bin/mocp -i); do

  # Parse mocp output.
  while IFS=: read -r field value; do
    case $field in
      Artist) artist=$value;;
      Album) album=$value;;
      SongTitle) title=$value;;
    esac
  done <<< "$out"

  # Don't do anything if we're still on the same song.
  [[ "$artist-$album-$title" = "$current" ]] && { sleep 1; continue; }

  # Growl notify this information
  if [[ $album && $artist && $title ]]; then
    /usr/local/bin/growlnotify -t "moc: $title" -n "mocp" -m "by $artist"$'\n'"(album: $album)"
  fi

  # Remember the current song.
  current="$artist-$album-$title"

done
