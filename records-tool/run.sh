#!/bin/bash
{

set -eo pipefail

nlist=$1
statsa="day mon run-7 run-30 timsel"
statsm="max sum"

./main/year-split.sh $nlist
for sa in $statsa; do
  if [ $sa != day ]; then
    tdir=.tempscripts
    mkdir -p $tdir
    for sm in $statsm; do
      saa=$( echo $sa | cut -d'-' -f1 )
      sam=$saa$sm
      if [ $saa = timsel ]; then
        nd=7
      elif [ $saa = run ]; then
        nd=$( echo $sa | cut -d'-' -f2 )
      else
        nd=1
      fi
      newscr=$tdir/$( echo $nlist | cut -d'.' -f1 )-$sam-${nd}.list
      cp $nlist $newscr
      sed -i $newscr -e "s/stat = .*$/stat = '"${sam}"'/"
      sed -i $newscr -e "s/s_nd = .*$/s_nd = '"${nd}"'/"
      ./main/stats.sh $newscr
      ./main/records.sh $newscr
    done
  fi
done

}
