#!/usr/bin/env bash
# Regenerates every Android icon resource from the SVG sources in this
# directory. Run it after editing any of them; the PNGs are checked in so a
# normal build needs neither this script nor rsvg-convert.
#
#   brew install librsvg && design/logo/generate.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
res="$here/../../android/app/src/main/res"

# Density buckets, as a multiple of mdpi.
buckets=(mdpi:1 hdpi:1.5 xhdpi:2 xxhdpi:3 xxxhdpi:4)

render() { # svg  base-dp  output-name
  local svg="$1" base="$2" name="$3"
  for bucket in "${buckets[@]}"; do
    local dir="${bucket%%:*}" scale="${bucket##*:}"
    local px
    px=$(printf '%.0f' "$(echo "$base * $scale" | bc -l)")
    mkdir -p "$res/mipmap-$dir"
    rsvg-convert -w "$px" -h "$px" "$here/$svg" -o "$res/mipmap-$dir/$name"
  done
}

# Legacy launcher icon: 48dp, already masked into its own rounded square.
render legacy.svg 48 ic_launcher.png
# Adaptive layers: 108dp, with the mark inside the 66dp safe zone.
render mark.svg 108 ic_launcher_foreground.png
render monochrome.svg 108 ic_launcher_monochrome.png
# Notification small icon: Android draws it as an alpha mask, so it must be
# the flat monochrome mark and nothing else. 24dp.
for bucket in "${buckets[@]}"; do
  dir="${bucket%%:*}"; scale="${bucket##*:}"
  px=$(printf '%.0f' "$(echo "24 * $scale" | bc -l)")
  mkdir -p "$res/drawable-$dir"
  rsvg-convert -w "$px" -h "$px" "$here/monochrome.svg" -o "$res/drawable-$dir/ic_notification.png"
done

echo "regenerated icons under $res"
