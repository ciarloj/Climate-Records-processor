#!/bin/bash
{
set -eo pipefail

nlist=$1
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
st=$( cat $nlist | grep 'stat =' | cut -d"'" -f2 )
nd=$( cat $nlist | grep 's_nd =' | cut -d"'" -f2 )

hdir=$wkd/$jm/$dn
ydir=$hdir
if [ $st != monmax -a $st != monsum ]; then
  ydir=$hdir/trim
fi
if [ $st != day ]; then
  sdir=${st}-$nd
  [[ $st = monmax ]] && sdir=$st
  [[ $st = monsum ]] && sdir=$st
  ydir=$ydir/$sdir
else
  sdir=day
fi
ddir=$ydir/records/sum
din=$ddir/index.nc

gridf=$wkd/$jm/REGCM-ERAIN/1980.nc
dremp=$ddir/index_remap.nc
if [ ! -f $dremp ]; then
  cdo -O -L -f nc4 -z zip remapdis,$gridf $din $dremp
fi

idir=$wkd/$jm/images
mkdir -p $idir

args='idir="'$idir'" stat="'$sdir'" fnam="'$dremp'" yr1="'$y1'" yr2="'$y2'" dn="'$dn'"'
ncl -Q $args tools/regression.ncl

}