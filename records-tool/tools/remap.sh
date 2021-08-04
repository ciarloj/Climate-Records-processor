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
rel=$( cat $nlist | grep 'remaplog =' | cut -d"'" -f2 )
ret=$( cat $nlist | grep 'remaptyp =' | cut -d"'" -f2 )
gf=$( cat $nlist | grep 'gridfile =' | cut -d"'" -f2 )

if [ $rel != 'true' ]; then
  echo "NOTE: remap logic set to 'false'"
  echo "no remap required"
  exit 0
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
din=$ddir/index.nc

dremp=$ddir/index_remap.nc
cdo -O -L -f nc4 -z zip remap$ret,$gf $din $dremp

echo "Complete."

}
