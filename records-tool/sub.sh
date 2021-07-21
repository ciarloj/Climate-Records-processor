#!/bin/bash
{

set -eo pipefail

nlist=$1
statsa="day mon run-7 run-30 timsel"
statsm="max sum"
statsa="run-30"
statsm="max"

jid=$( bash sub_one.sh main/year-split.sh $nlist | cut -d' ' -f4 )
dep1="-d afterok:$jid"
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
      newscr=$tdir/$( basename $nlist | cut -d'.' -f1 )-$sam-${nd}.list
      cp $nlist $newscr
      sed -i $newscr -e "s/stat = .*$/stat = '"${sam}"'/"
      sed -i $newscr -e "s/s_nd = .*$/s_nd = '"${nd}"'/"
      jid2=$( bash sub_one.sh main/stats.sh $newscr "$dep1" | cut -d' ' -f4 )
      dep2="-d afterok:$jid2"
      bash sub_one.sh main/records.sh $newscr "$dep2"
    done
  else
    bash sub_one.sh main/records.sh $nlist "$dep1"
  fi
done

}
