#!/bin/bash
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

ps=F # T or F : process skip
nlist=$1
v=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
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
inf1=$ydir/{${y1}..${y2}}.nc
inf2=$ydir/{${y3}..${y4}}.nc
[[ $ps != T ]] && eval CDO timmean -mergetime $inf1 $omf
[[ $ps != T ]] && eval CDO timmean -mergetime $inf2 $nmf

cf=$cdir/${tpo}_${tpn}.nc
[[ $ps != T ]] && eval CDO sub $nmf $omf $cf

idir=$wkd/$jm/images
mkdir -p $idir

dfil=$cf
dn=$( echo $dn | sed -e 's|/|-|' )
dn=$( echo $dn | sed -e 's/E_OBS/E-OBS/' )

# control dimensionality of lat/lon
set +e
stn1='standard_name = "latitude"'
stn2='standard_name = "longitude"'
dim1=$( ncdump -h $dfil | grep "$stn1" | cut -d':' -f1 | cut -d$'\t' -f3 )
dim2=$( ncdump -h $dfil | grep "$stn2" | cut -d':' -f1 | cut -d$'\t' -f3 )
dimt=$( ncdump -h $dfil | grep " ${dim1}(" | head -1 | grep ',' )
set -e
[[ ! -z "$dimt" ]] && dimsz=2d || dimsz=1d

args='idir="'$idir'" stat="'$sdir'" fnam="'$dfil'" tpo="'$tpo'" tpn="'$tpn'" dn="'$dn'" v="'$v'" tdim="'$dimsz'" dim1="'$dim1'" dim2="'$dim2'"'
ncl -Q $args tools/plot_change.ncl

echo "Complete."

}
