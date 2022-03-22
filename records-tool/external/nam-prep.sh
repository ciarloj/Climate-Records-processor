#!/bin/bash
{
set -eo pipefail
f=$1
fyr=$2
lyr=$3
od=$4

CDO(){
  cdo -O -L -f nc4 -z zip $@ 
}
echo "## Processing: "
echo "     $f"
echo "     $od"

mkdir -p $od
for y in $( seq $fyr $lyr ); do
  echo "$y .."
  of=$od/${y}.nc
  CDO mulc,86400 -selyear,$y $f $of
  ncatted -O -a units,pr,m,c,"mm/day" $of
done

  


}
