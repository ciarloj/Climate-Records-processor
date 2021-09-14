#!/bin/bash
{
set -eo pipefail

nlist=$1
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
tpo=$2 #old time period ex. 1970-2000
tpn=$3 #new time period ex. 2070-2100

y1=$( echo $tpo | cut -d'-' -f1 )
y2=$( echo $tpo | cut -d'-' -f2 )
y3=$( echo $tpn | cut -d'-' -f1 )
y4=$( echo $tpn | cut -d'-' -f2 )

hdir=$wkd/$jm/$dn
ydir=$hdir
mdir=$ydir/means
cdir=$mdir/change
mkdir -p $cdir

omf=$mdir/${tpo}.nc
nmf=$mdir/${tpn}.nc
eval cdo -O -L -f nc4 -z zip timmean -mergetime $ydir/{${y1}..${y2}}.nc $omf
eval cdo -O -L -f nc4 -z zip timmean -mergetime $ydir/{${y3}..${y4}}.nc $nmf

cf=$cdir/${tpo}_${tpn}.nc
eval cdo -O -L -f nc4 -z zip sub $nmf $omf $cf

echo "Complete."

}
