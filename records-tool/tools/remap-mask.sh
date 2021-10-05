#!/bin/bash
#SBATCH -o /home/netapp-clima-scratch/jciarlo/records/logs/r-m-remo-hist_SLURM.out
#SBATCH -e /home/netapp-clima-scratch/jciarlo/records/logs/r-m-remo-hist_SLURM.err
#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH -J r-m-remo-hist
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jciarlo@ictp.it
#SBATCH -p esp
{
set -eo pipefail

grid=/home/netapp-clima-scratch/jciarlo/records/E_OBS/data-mask.nc
od=proc
mkdir -p $od
for f in $( ls pr_*.nc ); do
  y1=$( basename $f | cut -d'_' -f9 | cut -c1-4 )
  y2=$( basename $f | cut -d'_' -f9 | cut -d'-' -f2 | cut -c1-4 )
  for y in $( seq $y1 $y2 ); do
    echo $y ..
    bn=$od/${y}.nc
    cdo -O -L -f nc4 -z zip selyear,$y $f ${bn}_tmp.nc
    cdo -O -L -f nc4 -z zip remapdis,$grid ${bn}_tmp.nc $bn
    cdo -O -L -f nc4 -z zip mulc,86400 $bn ${bn}_tmp.nc
    mv ${bn}_tmp.nc $bn
    set +e
    nts=$( ncdump -h $bn | grep 'time' | head -1 | cut -d'(' -f2 | cut -d' ' -f1 )
    set -e
    cdo -O -L -f nc4 -z zip duplicate,$nts $grid ${bn}_mask.nc
    cdo -O -L -f nc4 -z zip merge $bn ${bn}_mask.nc ${bn}_mask2.nc
    cdo -O -L -f nc4 -z zip expr,"m=(mask>=0)?pr:-9999" ${bn}_mask2.nc ${bn}_tmp.nc
    cdo -O -L -f nc4 -z zip chname,m,pr -setctomiss,-9999 ${bn}_tmp.nc $bn
    rm ${bn}_mask.nc ${bn}_mask2.nc ${bn}_tmp.nc
  done
done
ncatted -O -a units,pr,m,c,"mm/day" ${y}.nc

}
