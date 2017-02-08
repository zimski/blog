#!/bin/sh

FILES=`find ../assets/images/post_cover/*jpg | grep -v resized`

for file in $FILES
do
    echo "Processing image: $file"
    bash ./textcleaner -g -e stretch -f 60 -o 3 -s 1  $file $file
    echo "Processing Image done"
    echo "Resizing Image: $file"
    convert $file -resize 560x300 ${file/.jpg/_resized.jpg}
    echo "Resizing Image done"

    rm $file
done
