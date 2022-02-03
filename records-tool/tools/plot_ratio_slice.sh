#!/bin/bash
{
set -eo pipefail

nlist=$1
tslice=Y #Y or N
[[ $tslice = Y ]] && tper=$2
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
st=$( cat $nlist | grep 'stat =' | cut -d"'" -f2 )
nd=$( cat $nlist | grep 's_nd =' | cut -d"'" -f2 )
rel=$( cat $nlist | grep 'remaplog =' | cut -d"'" -f2 )
msl=$( cat $nlist | grep 'masklog =' | cut -d"'" -f2 )

yo1=$y1
yo2=$y2
if [ $tslice = Y ]; then
  y1a=$( echo $tper | cut -d'-' -f1 )
  y2a=$( echo $tper | cut -d'-' -f2 )
  c=0
  for n in $( seq $y1 $y1a ); do
    n1=$c
    c=$((c+1))
  done
  n2=$(( $y2a - $y1 ))
  y1=$y1a
  y2=$y2a
else
  n1=0
  n2=$(( $y2 - $y1 ))
fi

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
if [ $rel = 'true' -a $msl = 'true' ]; then
  dnam=index_remap_mask
elif [ $rel = 'true' -a $msl = 'false' ]; then
  dnam=index_remap
elif [ $rel = 'false' -a $msl = 'true' ]; then
  echo "ERROR! remap = false + mask = true"
  exit 1
else
  dnam=index
fi
din=$ddir/${dnam}_fld_norm.nc

idir=$wkd/$jm/images
mkdir -p $idir

args='idir="'$idir'" stat="'$sdir'" fnam="'$din'" yr1="'$y1'" yr2="'$y2'" dn="'$dn'" n1="'$n1'" n2="'$n2'" yo1="'$yo1'" yo2="'$yo2'"'
ncl -Q $args tools/plot_ratio_slice.ncl

}
