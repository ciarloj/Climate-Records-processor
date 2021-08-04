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
msl=$( cat $nlist | grep 'masklog =' | cut -d"'" -f2 )
mf=$( cat $nlist | grep 'maskfil =' | cut -d"'" -f2 )

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
  dnam=index_remap_mask.nc
elif [ $rel = 'true' -a $msl = 'false' ]; then
  dnam=index_remap.nc
elif [ $rel = 'false' -a $msl = 'true' ]; then
  echo "ERROR! remap = false + mask = true"
  exit 1
else
  dnam=index.nc
fi
din=$ddir/$dnam

dout=$ddir/$( basename $din | cut -d'.' -f1 )_fld_norm.nc

cdo -O -L -f nc4 -z zip chname,nn,n -selvar,nn -aexpr,"nn=n/p" -fldsum $din $dout

echo "Complete."

}
