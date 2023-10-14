#!/bin/bash
{
set -eo pipefail

datasets="mswep cpc era5 merra jra-55"
datasets="mswep"

for ds in $datasets; do
  nl=mynamelists/${ds}.list

  domains="land ocean"
  [[ $ds = cpc ]] && domains="land"
  hemispheres="N S"
  bands="tropics midlats polar"

  sed -i $nl -e "s|stat = .*$|stat = 'runmax'|"
  sed -i $nl -e "s|s_nd = .*$|s_nd = '30'|"
  bash tools/plot.sh $nl 

  for d in $domains; do
    dnd=${ds}-${d}
    nld=mynamelists/${dnd}.list
    sed -i $nld -e "s|stat = .*$|stat = 'runmax'|"
    sed -i $nld -e "s|s_nd = .*$|s_nd = '30'|"
    bash tools/plot.sh $nld 

    for h in $hemispheres; do
      for b in $bands; do
        dnd=${ds}-${h}-${b}-${d}
        nld=mynamelists/${dnd}.list
        sed -i $nld -e "s|stat = .*$|stat = 'runmax'|"
        sed -i $nld -e "s|s_nd = .*$|s_nd = '30'|"
        bash tools/plot.sh $nld 
      done
    done
  done

done

}
