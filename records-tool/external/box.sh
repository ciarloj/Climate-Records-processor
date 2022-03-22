#!/bin/bash
#SBATCH -J era-box
#SBATCH -p esp
#SBATCH -t 24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

doms="NAM CAM SAM AFR WAS EAS SEA AUS EUR"
doms=$1

for d in $doms; do

#lonE,lonW,latS,latN
[[ $d = NAM ]] && box="-169,-47,23,75"
[[ $d = CAM ]] && box="-120,-40,-2,35"
[[ $d = SAM ]] && box="-89,-30,-58,14"
[[ $d = AFR ]] && box="-26.7,60.8,-37.6,42."
[[ $d = WAS ]] && box="55,95,2,47"
[[ $d = EAS ]] && box="86,166,5,62"
[[ $d = SEA ]] && box="88,157,-12,26"
[[ $d = AUS ]] && box="109,180,-51,-8"
[[ $d = CAS ]] && box="35,120,25,68"
[[ $d = EUR ]] && box="-12,42,30,72"


echo "## $d .."
od=${d}-ERA5
mkdir -p $od
for f in $( ls ????.nc ); do
  of=$od/$f
  echo $f ..
  CDO sellonlatbox,$box $f $of
done

done
}
