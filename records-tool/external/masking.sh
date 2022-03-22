#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
#SBATCH -p esp
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

d=$1
ddir=$d
odir=$ddir/orig
if [ ! -d $odir ]; then
  mkdir -p $odir
  mv $ddir/????.nc $odir/
fi

dom=$( echo $d | cut -d- -f1 )
rcm=$( echo $d | cut -d- -f2 )
[[ $rcm = REGCM ]] && rrr=RegCM || rrr=REMO
maskf=$( ls sftlf_${dom}-??_*${rrr}*.nc )
echo $maskf

[[ $dom = AFR ]] && box="-26.7,60.8,-37.6,42."
[[ $dom = CAM ]] && box="-130,-28,-21,49"
[[ $dom = WAS ]] && box="24,112,2,47"
if [ $dom = AFR -a $rrr = RegCM ]; then
  mask2f=AFR-mini-mask.nc
  CDO sellonlatbox,"$box" $maskf $mask2f
  maskf=$mask2f
fi

echo "## $d"
for f in $( ls $odir/????.nc ); do
  y=$( basename $f | cut -d. -f1 )
  echo $y .. 
  nf=$ddir/${y}.nc
  cp $f $nf

  set +e
  nts=$( ncdump -h $nf | grep 'time' | head -1 | cut -d'(' -f2 | cut -d' ' -f1 )
  set -e
  CDO duplicate,$nts $maskf ${d}_mask-t.nc
  CDO merge $nf ${d}_mask-t.nc ${d}_mask2.nc
  CDO expr,"prm=(sftlf==0)?-9999:pr" ${d}_mask2.nc ${d}_tmp.nc
  CDO chname,prm,pr -setctomiss,-9999 ${d}_tmp.nc $nf
  rm ${d}_mask-t.nc ${d}_mask2.nc ${d}_tmp.nc
  if [ $dom = CAM -o $dom = WAS ]; then
    CDO sellonlatbox,"$box" $nf ${nf}_tmp.nc
    mv ${nf}_tmp.nc $nf
  elif [ $dom = AFR -a $rrr = REMO ]; then
    CDO sellonlatbox,"$box" $nf ${nf}_tmp.nc
    mv ${nf}_tmp.nc $nf
  fi
  
done
if [ $dom = AFR -a $rrr = RegCM ]; then
  rm AFR-mini-mask.nc
fi


}
