#!/bin/bash
{
set -eo pipefail

ds=$1
nl=mynamelists/${ds}.list

domains="land ocean"
[[ $domains = CPC ]] && domains="land"
hemispheres="N S"
bands="tropics midlats polar"

dnam=$( cat $nl | grep 'd_nam =' | cut -d"'" -f2 )
echo "submitting $dnam ..."
bash sub.sh $nl ann

for d in $domains; do
  dnamd=${dnam}-${d}
  echo "submitting $dnamd ..."
  nld=mynamelists/${ds}-${d}.list
  cp $nl $nld
  sed -i $nld -e "s|d_nam = .*$|d_nam = '"${dnamd}"'|" 
  bash sub.sh $nld ann
 
  for h in $hemispheres; do
    for b in $bands; do
      dnamd=${dnam}-${h}-${b}-${d}
      echo "submitting $dnamd ..."
      nld=mynamelists/${ds}-${h}-${b}-${d}.list
      cp $nl $nld
      sed -i $nld -e "s|d_nam = .*$|d_nam = '"${dnamd}"'|"
      bash sub.sh $nld ann
    done
  done
done



}
