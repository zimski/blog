#!/bin/sh

FILES=`find ../assets/images/post_cover/*jpg | grep -v resized`

for file in $FILES
do
    echo "Resizing Image: $file"
    convert $file -resize 560x300 ${file/.jpg/_resized.jpg}
    echo "Resizing Image done"
    rm $file
done
