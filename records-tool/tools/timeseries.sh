#!/bin/bash
{
set -eo pipefail

ps=F # T or F : process skip
nlist=$1
v=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )

hdir=$wkd/$jm/$dn
ydir=$hdir
mdir=$ydir/fldtimmean
mkdir -p $mdir

for y in $( seq $y1 $y2 ); do
  echo $y ..
  inf=$ydir/${y}.nc
  of=$mdir/${y}.nc
  [[ $ps != T ]] && eval cdo -O -L -f nc4 -z zip timmean -fldmean $inf $of
done

infs=$mdir/{${y1}..${y2}}.nc
mf=$mdir/merge.nc
[[ $ps != T ]] && eval cdo -O -L -f nc4 -z zip mergetime $infs $mf

#idir=$wkd/$jm/images
#mkdir -p $idir

#dfil=$cf
#dn=$( echo $dn | sed -e 's|/|-|' )
#dn=$( echo $dn | sed -e 's/E_OBS/E-OBS/' )
#args='idir="'$idir'" stat="'$sdir'" fnam="'$dfil'" tpo="'$tpo'" tpn="'$tpn'" dn="'$dn'" v="'$v'"'
#ncl -Q $args tools/plot_change.ncl

echo "Complete."

}
