#!/bin/bash
{

set -eo pipefail

tpo=1970-2000
tpn=2070-2100
ssn=$1 #ann DJF MAM JJA SON
dlist="regcm-mpi-85 regcm-mpi-26 remo-mpi-85 remo-mpi-26"
dlist="tas-regcm-mpi-85 tas-regcm-mpi-26"

echo "## $ssn : $tpn - $tpo"
for d in $dlist; do
  echo "## $d"
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
  ./tools/change.sh $nl $tpo $tpn
done
echo done

}
