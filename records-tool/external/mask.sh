#!/bin/bash
#SBATCH -J era5-mask
#SBATCH -p esp
#SBATCH -t 24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

mf=/home/clima-archive5/ERA5/fixed/landmask.nc

mkdir -p masked
for f in $( ls ????.nc ); do 
  echo $f ..
  of=masked/$f
  
  cp $f $of
  set +e
  nts=$( ncdump -h $of | grep 'time' | head -1 | cut -d'(' -f2 | cut -d' ' -f1 )
  set -e
  CDO duplicate,$nts $mf ${of}_mask-t.nc
  CDO merge $of ${of}_mask-t.nc ${of}_mask2.nc
  CDO expr,"m=(lsm==0)?-9999:pr" ${of}_mask2.nc ${of}_tmp.nc
  CDO chname,m,pr -setctomiss,-9999 ${of}_tmp.nc $of
  rm ${of}_mask-t.nc ${of}_mask2.nc ${of}_tmp.nc
done


}
