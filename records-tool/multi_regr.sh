#!/bin/bash
{

set -eo pipefail

ssn=$1 #ann DJF MAM JJA SON
#dlist="eobs era5 regcm-erain"
#tslice=N
dlist="regcm-mpi-85 regcm-mpi-26 remo-mpi-85 remo-mpi-26"
tslice=Y #Y or N
[[ $tslice = Y ]] && tper=2010-2100 || tper=""

for d in $dlist; do
  echo "## $ssn : $d"
  nlist=mynamelists/${d}.list
  if [ $ssn != ann ]; then
    tdir=.tempscripts
    mkdir -p $tdir
    newscr=$tdir/$( basename $nlist | cut -d'.' -f1 )-${ssn}.list
    cp $nlist $newscr
    dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
    sed -i $newscr -e "s|d_nam = .*$|d_nam = '"${dn}/${ssn}"'|"
    nl=$newscr
  else
    nl=$nlist
  fi 
  ./tools/regression.sh $nl $tslice $tper
done
echo done

}
