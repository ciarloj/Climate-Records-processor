#!/bin/bash
#SBATCH -p esp
#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=jciarlo@ictp.it
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

nlist=$1
pp=95

v=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
set +e
ym=$( cat $nlist | grep 'myr =' | cut -d"'" -f2 )
set -e
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )

select=""
[[ $dn = GPCP ]] && select="-selvar,$v"

domains="global land ocean"
[[ $dn = CPC ]] && domains="global land"
hemispheres="G N S"
bands="tropics midlats polar"

for d in $domains; do
  [[ $d = global ]] && hemi="all" || hemi="$hemispheres" 
  [[ $d = global ]] && band="all" || band="$bands"
  for h in $hemi; do
    [[ $h = G ]] && band="all" || band="$bands"
    for b in $band; do
      dnn=${dn}-${h}-${b}-${d}
      [[ $d = global ]] && dnn=$dn
      [[ $h = G ]] && dnn=${dn}-$d
      
      echo "#### Processing $dnn ####"
#repeat from here


hdir=$wkd/$jm/$dnn
rdir=$hdir/rainy
mkdir -p $rdir
echo "### Select rainy (pr>1mm) days ..."
for y in $( seq $y1 $y2 ); do
  echo ".. $y .."
  yf=$hdir/${y}.nc
  rf=$rdir/${y}.nc
  [[ ! -f $rf ]] && CDO setrtomiss,-Inf,0.99999 $select $yf $rf
done

pdir=$rdir/p$pp
mkdir -p $pdir

tper=${y1}-${y2}
mxf=$pdir/max_${tper}.nc
mnf=$pdir/min_${tper}.nc
tsf=$pdir/ts_${tper}.nc
ppf=$pdir/p${pp}_${tper}.nc

infs=$rdir/{${y1}..${y2}}.nc
if [ ! -f $ppf ]; then 
echo "### Calculating p$pp .."
  CDO mergetime $( eval ls $infs ) $tsf
  CDO timmax $tsf $mxf
  CDO timmin $tsf $mnf
  CDO timpctl,$pp $tsf $mnf $mxf $ppf
  rm $tsf $mxf $mnf
fi

rtdir=$pdir/Rtot
rpdir=$pdir/R$pp
rxdir=$pdir/Rm$pp
rfdir=$pdir/Rf$pp
mkdir -p $rtdir $rpdir $rxdir $rfdir
ntdir=$pdir/ndaytot
npdir=$pdir/ndayR$pp
nxdir=$pdir/ndayRm$pp
nfdir=$pdir/ndayfR$pp
mkdir -p $ntdir $npdir $nxdir $nfdir
echo "### Calculating R$pp related indices .."
for y in $( seq $y1 $y2 ); do
  echo ".. $y .."
  yf=$rdir/${y}.nc
  
  rtf=$rtdir/${y}.nc
  if [ ! -f $rtf ]; then
    CDO timsum $yf $rtf
    ncatted -O -a long_name,$v,m,c,"Total Annual Rainfall (>1mm/day)" $rtf
    ncatted -O -a units,$v,m,c,"mm" $rtf
  fi

  rpf=$rpdir/${y}.nc
  if [ ! -f $rpf ]; then
    CDO ifthen -ge $yf $ppf $yf $rpf
    CDO timsum $rpf ${rpf}_sum.nc
    mv ${rpf}_sum.nc $rpf
    ncatted -O -a long_name,$v,m,c,"Total Annual Rainfall (>1mm/day) above p$pp" $rpf
    ncatted -O -a units,$v,m,c,"mm" $rpf
  fi

  rxf=$rxdir/${y}.nc
  if [ ! -f $rxf ]; then
    CDO ifthen -lt $yf $ppf $yf $rxf
    CDO timsum $rxf ${rxf}_sum.nc
    mv ${rxf}_sum.nc $rxf
    ncatted -O -a long_name,$v,m,c,"Total Annual Rainfall (>1mm/day) below p$pp" $rxf
    ncatted -O -a units,$v,m,c,"mm" $rxf
  fi

  rff=$rfdir/${y}.nc
  if [ ! -f $rff ]; then
    CDO div $rpf $rtf $rff
    ncatted -O -a long_name,$v,m,c,"Total Rainfall fraction (>1mm/day) above p$pp" $rff
    ncatted -O -a units,$v,m,c,"#" $rff
  fi

  ntf=$ntdir/${y}.nc
  if [ ! -f $ntf ]; then
    CDO timsum -gec,1 $yf $ntf
    ncatted -O -a long_name,$v,m,c,"Total number of wet days (>1mm/day)" $ntf
    ncatted -O -a units,$v,m,c,"days" $ntf
  fi

  npf=$npdir/${y}.nc
  if [ ! -f $npf ]; then
    CDO timsum -ge $yf $ppf $npf
    ncatted -O -a long_name,$v,m,c,"Total number of wet days (>1mm/day) above p$pp" $npf
    ncatted -O -a units,$v,m,c,"days" $npf
  fi

  nxf=$nxdir/${y}.nc
  if [ ! -f $nxf ]; then
    CDO timsum -lt $yf $ppf $nxf
    ncatted -O -a long_name,$v,m,c,"Total number of wet days (>1mm/day) below p$pp" $nxf
    ncatted -O -a units,$v,m,c,"days" $nxf
  fi

  nff=$nfdir/${y}.nc
  if [ ! -f $nff ]; then
    CDO div $npf $ntf $nff
    ncatted -O -a long_name,$v,m,c,"Fraction of total wet days (>1mm/day) above p$pp" $nff
    ncatted -O -a units,$v,m,c,"#" $nff
  fi

done

echo "#### completed $dnn ####"

    done
  done
done


echo "Script Complete."

}
