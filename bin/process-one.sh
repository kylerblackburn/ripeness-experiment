#!/bin/bash
# usage: process-one.sh photo position outdir
#
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

in=$1
id=$2
outdir=$3
file=${in##*/}
base=${file%.*}
out=$outdir/$base-$id.png;

# NOTE: DSC08871 has 7 & 8 transposed
if [[ "$base" = "DSC08871" ]]; then
    if [[ "$id" -eq "7" ]]; then
	id=8
    elif [[ "$id" -eq "8" ]]; then
	id=7
    fi
fi

col=$(( (id - 1) % 4))
row=$(( (id - 1) / 4))

# determine x and y offsets for this tile within the photo
# 792 5056
# 797 5890
# 804 5080
# 811 5300
# 819 5300
# 826 5300
# 837 5310
# 845 5305
# 855 5305
# 863 5305
# 871 5310

if [[ $base = "DSC08792" || $base = "DSC08797" || $base = "DSC08804" ]]; then
    xpitch=$(( 5080/4 ))
    xoff=500
else
    xpitch=$(( 5300/4 ))
    xoff=420
fi
    


# position of this piece of fruit in the big photo (4 x 2 grid)
y=$((2000 * $row))
x=$(($xoff + ($col * $xpitch)))

# cropping this piece of fruit
convert $in -crop $xpitch"x2000+"$x+$y $out

#
# find the bounding box that tightly crops this piece of fruit
#
# get rid of the background by getting rid of close to white (paper), grey (shadows) and grey (pencil) and then cropping
convert $out -fuzz 10% -transparent '#b8b8b8' -fuzz 10% -transparent '#707070' -fuzz 10% -transparent '#a0a0a0' -fuzz 10% -transparent '#d0d0d0' -fuzz 10% -transparent white -fuzz 10% $outdir/$base-$id-crop.png
# finding the midpoint and using the magic wand to keep similar stuff and get rid of other background stuff
xmid=$(( $xpitch / 2 ))
ymid=1000
$DIR/magicwand.sh $xmid,$ymid -t 25 -c transparent $outdir/$base-$id-crop.png $outdir/$base-$id-wand.png
# trimming, getting rid of transparent stuff
convert $outdir/$base-$id-wand.png -trim $outdir/$base-$id-crop.png
# calculating the bounds of the picture relative to the big picture
width=`convert $outdir/$base-$id-crop.png -format "%w" info:`
height=`convert $outdir/$base-$id-crop.png -format "%h" info:`
ulx=`convert $outdir/$base-$id-crop.png -format "%X" info:`
uly=`convert $outdir/$base-$id-crop.png -format "%Y" info:`
ulxabs=`convert $outdir/$base-$id-crop.png -format "%[fx:$ulx+$x]" info:`
ulyabs=`convert $outdir/$base-$id-crop.png -format "%[fx:$uly+$y]" info:`
# echo "ulx=$ulx; uly=$uly; ulxabs=$ulxabs; ulyabs=$ulyabs;"
cr=$width"x"$height"+"$ulxabs"+"$ulyabs


#
# having found the exact location of the piece of fruit, creating final images of it
#
# echo "cr=$cr"
# starting again with the simple crop, getting rid of close to white (paper), grey (shadows) and grey (pencil)
convert $out -crop $cr -fuzz 10% -transparent '#b8b8b8' -fuzz 10% -transparent '#707070' -fuzz 10% -transparent '#a0a0a0' -fuzz 10% -transparent '#d0d0d0' -fuzz 10% -transparent white -fuzz 10% $outdir/$base-$id-crop.png
# again using the magic wand to select the piece of fruit
xmid=$(( $width/3 )) #don't take middle because bend in bananas
ymid=$(( $height/2 ))
$DIR/magicwand.sh $xmid,$ymid -t 50 -c transparent $outdir/$base-$id-crop.png $outdir/$base-$id-wand.png
# dithering to make the image a small number of representative colours
convert $outdir/$base-$id-wand.png +dither -colors 4 $outdir/$base-$id-dither.png
# creating a square image with the fruit in the middle
convert $outdir/$base-$id-crop.png -gravity center -background transparent -extent 1250x1250 $outdir/$base-$id-sq.png
# making a 1x1 version of the image, getting the average colour
convert $outdir/$base-$id-wand.png -scale 1x1! -alpha off $outdir/$base-$id-1x1.png;
# printing out average colour in rgb format
echo -n "$base-$id "
convert $outdir/$base-$id-1x1.png -format "%[pixel:u.p]" info:;
echo;
# turning the 1x1 average into a 100x100 of the same colour
convert $outdir/$base-$id-1x1.png -scale 100x100! $outdir/$base-$id-100x100.png;

exit

#convert $out -fuzz 10% -transparent '#b8b8b8' -fuzz 10% -transparent '#707070' -fuzz 10% -transparent '#a0a0a0' -fuzz 10% -transparent '#d0d0d0' -fuzz 10% -transparent white -trim $outdir/$base-$id-crop.png;
# convert $out -fuzz 10% -transparent '#b8b8b8' -fuzz 10% -transparent '#707070' -fuzz 10% -transparent '#a0a0a0' -fuzz 10% -transparent '#d0d0d0' -fuzz 10% -transparent white -fuzz 10% -transparent '#342427' -fuzz 10% -transparent '#505050' -trim $outdir/$base-$id-crop.png;
#convert $out -fuzz 30% -transparent black -fuzz 33% -transparent '#b8b8b8' -fuzz 10% -trim $outdir/$base-$id-crop.png;

# echo $cr
#convert $in -crop $cr -fuzz 50% -transparent white $outdir/$base-$id-crop.png
