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

if [ $msl != 'true' ]; then
  echo "NOTE: masking logic set to 'false'"
  echo "no mask required"
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
[[ $rel = 'true' ]] && din=$ddir/index_remap.nc

dout=$ddir/$( basename $din | cut -d'.' -f1 )_mask.nc

cp $din $dout
set +e
nts=$( ncdump -h $dout | grep 'time' | head -1 | cut -d'(' -f2 | cut -d' ' -f1 )
set -e
cdo -O -L -f nc4 -z zip duplicate,$nts $mf ${dout}_mask-t.nc
cdo -O -L -f nc4 -z zip merge $din ${dout}_mask-t.nc ${dout}_mask2.nc
cdo -O -L -f nc4 -z zip expr,"m=(sftlf==0)?-9999:n ; mp=(sftlf==0)?-9999:p" ${dout}_mask2.nc ${dout}_tmp.nc
cdo -O -L -f nc4 -z zip chname,m,n -chname,mp,p -setctomiss,-9999 ${dout}_tmp.nc $dout
rm ${dout}_mask-t.nc ${dout}_mask2.nc ${dout}_tmp.nc

echo "Complete."

}
