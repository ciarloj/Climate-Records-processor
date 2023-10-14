#!/bin/bash
{
set -eo pipefail

dep=$1
ldir=/home/netapp-clima-scratch/jciarlo/records/logs

datasets="mswep cpc era5 merra jra-55"
datasets=mswep
for ds in $datasets; do
  j="rainy_${ds}"
  o="$ldir/${j}.out"
  e="$ldir/${j}.err"
  nl=mynamelists/${ds}.list
  sbatch -J $j -o $o -e $e tools/rainy-days.sh $nl
done

}
