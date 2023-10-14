#!/bin/bash
{

export REMAP_EXTRAPOLATE=off
set -eo pipefail

nlist=$1
#statsa="day mon run-7 run-30 timsel"
statsa="run-30"   #quirimettererun-30
#statsm="max sum"
statsm="max"

echo "Executing year-split with nlist = $nlist"
./main/year-split.sh $nlist
echo "Before FOR loop"
for sa in $statsa; do
  echo "Running FOR loop with $sa"
  if [ $sa != day ]; then
    tdir=.tempscripts
    echo "Making dir $tdir"
    mkdir -p $tdir
    for sm in $statsm; do
      echo "Running FOR loop with $sm"
      saa=$( echo $sa | cut -d'-' -f1 )
      sam=$saa$sm
      if [ $saa = timsel ]; then
        nd=7
      elif [ $saa = run ]; then
        nd=$( echo $sa | cut -d'-' -f2 )
      else
        nd=1
      fi
      newscr=$tdir/$( echo $nlist | rev | cut -d'.' -f1 | rev | cut -d'.' -f1 )-$sam-${nd}.list
      cp $nlist $newscr
      sed -i $newscr -e "s/stat = .*$/stat = '"${sam}"'/"
      sed -i $newscr -e "s/s_nd = .*$/s_nd = '"${nd}"'/"
      echo "running stats.sh for $newscr"

      ./main/stats.sh $newscr

      echo "running records.sh for $newscr"

      ./main/records.sh $newscr
    done
  fi
done

}
