#!/bin/bash
#SBATCH -J trim-remo
#SBATCH -p esp
#SBATCH -t 24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

m=$1
d=$( echo $m | cut -d- -f1 )

#lonE,lonW,latS,latN
#[[ $d = NAM ]] && box="-169,-47,23,75"
[[ $d = CAM ]] && box="-120,-40,5,35"
#[[ $d = SAM ]] && box="-89,-30,-58,14"
#[[ $d = AFR ]] && box="-26.7,60.8,-37.6,42."
[[ $d = WAS ]] && box="55,95,2,47"
[[ $d = EAS ]] && box="86,166,5,62"
[[ $d = SEA ]] && box="88,157,-12,22"
[[ $d = AUS ]] && box="109,180,-51,-8"
#[[ $d = CAS ]] && box="35,120,25,68"
#[[ $d = EUR ]] && box="-12,42,30,72"


echo "## $m .."
od=$m/v2
if [ ! -d $od ]; then
  mkdir -p $od
  mv $m/????.nc $od/
fi
for f in $( ls $od/????.nc ); do
  of=$m/$( basename $f )
  echo $( basename $f ) ..
  CDO sellonlatbox,$box $f $of
done

}
