#!/bin/bash -x

dest_dir=Calendarly/Fonts
dest_plist=Calendarly/Info.plist
read -p "Where are you fonts located? " src

rm ${dest_dir}/*

find "${src}" -name "*.ttf" -exec cp '{}' "${dest_dir}" \;
/usr/libexec/PlistBuddy "${dest_plist}" -c "Delete UIAppFonts"
/usr/libexec/PlistBuddy "${dest_plist}" -c "Add UIAppFonts array"

idx=0
for font in Calendarly/Fonts/*;
do
  font_basename=`basename ${font}`
  /usr/libexec/PlistBuddy "${dest_plist}" -c "Add UIAppFonts:${idx} string ${font_basename}"
  idx=$(( idx + 1 ))
done
