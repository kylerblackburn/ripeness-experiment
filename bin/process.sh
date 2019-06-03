#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RESULTS=$DIR/../results

b=(DSC08792 DSC08797 DSC08804 DSC08811 DSC08819 DSC08826 DSC08837 DSC08845 DSC08855 DSC08863 DSC08871 DSC08879 DSC08887 DSC08899 DSC08906 DSC08914 )
t=(DSC08794 DSC08800 DSC08806 DSC08814 DSC08822 DSC08830 DSC08841 DSC08851 DSC08859 DSC08867 DSC08875 DSC08883 DSC08891 DSC08903 DSC08910 DSC08917)

n=(DSC08855)


function getOneSetOfColors() {
    local photo="$1"
    local id="$2"

    # get the single pixel colour
    one="$RESULTS/$photo-$id-1x1.png"
    oneout=($(convert $one -define histogram:unique-colors=true -format %c histogram:info:-|sed s/[\:\(\,\)]/\ /g))
    # the dithered colours and pixel numbers
    two="$RESULTS/$photo-$id-dither.png"
    twoout=($(convert $two -define histogram:unique-colors=true -format %c histogram:info:-|grep -v none|sed s/[\:\(\,\)]/\ /g))

    return="$photo, $id, "
    for i in 0 1 2 3; do
	return="$return ${oneout[$i]}, "
    done
    for i in 0 1 2 3 11 12 13 14 22 23 24 25; do
	return="$return ${twoout[$i]}, "
    done

    echo $return
}

# empty the csv file
csvfile="colours.csv"
rm -f $csvfile

#
# process all photos
#
for base in  ${b[@]} ${t[@]}; do
# for base in ${n[@]}; do
    for id in `seq 1 8`; do
#    for id in 8; do
	$DIR/process-one.sh originals/$base.JPG $id $RESULTS
	csv=$(getOneSetOfColors $base $id)
	echo $csv >> $csvfile
    done
done

function makeMontage() {
    local filename="$1"
    shift
    local photos=("$@")
    
    cfiles=""
    c5files=""
    for i in `seq 1 8`; do
	days=0
	for f in "${photos[@]}"; do
	    cfiles="$cfiles $RESULTS/$f-$i-crop.png"
	    c5files="$c5files $RESULTS/$f-$i-dither.png"
	    c100files="$c100files $RESULTS/$f-$i-100x100.png"
	    days=$(( $days + 1 ))
	done
    done
    montage $cfiles -tile $days"x8" -geometry 117x180+0+0 $filename.png
    montage $c5files -tile $days"x8" -geometry 117x180+0+0 $filename"2".png
    montage $c100files -tile $days"x8" -geometry 100x100+0+0 $filename"100".png
}

# makeMontage "bans" "${b[@]}"

makeMontage "bans" "${b[@]}"
makeMontage "toms" "${t[@]}"

#for x in ${b[@]}; do
##    gifset="$files $RESULTS/$x-$i-crop.png"
#    gifset="$files $RESULTS/$x-1-sq.png"
#done
#convert -loop 0 -delay 1 $gifset bananas.gif

