#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RESULTS=$DIR/../results

b=(DSC08792 DSC08797 DSC08804 DSC08811 DSC08819 DSC08826 DSC08837 DSC08845 DSC08855 DSC08863 DSC08871 DSC08879 DSC08887 DSC08899 DSC08906 DSC08914 )
t=(DSC08794 DSC08800 DSC08806 DSC08814 DSC08822 DSC08830 DSC08841 DSC08851 DSC08859 DSC08867 DSC08875 DSC08883 DSC08891 DSC08903 DSC08910 DSC08917)

n=(DSC08879 DSC08887 DSC08899 DSC08906 DSC08914 DSC08883 DSC08891 DSC08903 DSC08910 DSC08917)

#
# process all photos
#
for base in ${b[@]} ${t[@]}; do
# for base in DSC08792; do
#    for base in ${n[@]}; do
    for id in `seq 1 8`; do
	$DIR/process-one.sh originals/$base.JPG $id $RESULTS
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
	    cfiles="$cfiles $RESULTS/$f-$i.png"
	    c5files="$c5files $RESULTS/$f-$i-crop.png"
	    c100files="$c100files $RESULTS/$f-$i-100x100.png"
	    days=$(( $days + 1 ))
	done
    done
    montage $cfiles -tile $days"x8" -geometry 117x180+0+0 $filename.png
    montage $c5files -tile $days"x8" -geometry 117x180+0+0 $filename"5".png
    montage $c100files -tile $days"x8" -geometry 100x100+0+0 $filename"100".png
}

# makeMontage "bans" "${b[@]}"
# makeMontage "toms" "${t[@]}"

#for x in ${b[@]}; do
##    gifset="$files $RESULTS/$x-$i-crop.png"
#    gifset="$files $RESULTS/$x-1-sq.png"
#done
#convert -loop 0 -delay 1 $gifset bananas.gif

