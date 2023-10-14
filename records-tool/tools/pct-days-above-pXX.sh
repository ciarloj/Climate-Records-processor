#!/bin/bash
{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

nlist=$1
pp=99

v=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
set +e
ym=$( cat $nlist | grep 'myr =' | cut -d"'" -f2 )
set -e
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )

hdir=$wkd/$jm/$dn
pdir=$hdir/p$pp
ddir=$pdir/days
mkdir -p $ddir

tper=${y1}-${y2}
mxf=$pdir/max_${tper}.nc
mnf=$pdir/min_${tper}.nc
tsf=$pdir/ts_${tper}.nc
ppf=$pdir/p${pp}_${tper}.nc

infs=$hdir/{${y1}..${y2}}.nc

echo "### Calculating p$pp .."
eval CDO mergetime $infs $tsf
CDO timmax $tsf $mxf
CDO timmin $tsf $mnf
CDO timpctl,$pp $tsf $mnf $mxf $ppf
rm $tsf $mxf $mnf

echo "### Looking for days with $v above p$pp .."
for y in $( seq $y1 $y2 ); do
  echo ".. $y .."
  yf=$hdir/${y}.nc
  df=$ddir/${y}.nc
  set +e 
  ndays=$( ncdump -h $yf | grep 'time =' | cut -d'(' -f2 | cut -d' ' -f1 )
  set -e
  CDO mulc,100 -divc,$ndays -timsum -ge $yf $ppf $df
  ncatted -O -a long_name,$v,m,c,"Percentage of days with $v above p$pp in year" $df
  ncatted -O -a units,$v,m,c,"%" $df
done

echo "### Preparing masks .."
domains="land ocean"
for d in $domains; do
  maskf=$wkd/$jm/land/land_mask.nc
  remsk=$ddir/land_mask.nc
  [[ ! -f $remsk ]] && CDO remapdis,$ppf $maskf $remsk

  tdir=$ddir/$d
  mkdir -p $tdir
  for y in $( seq $y1 $y2 ); do
    echo ".. masking $d on $y .."
    df=$ddir/${y}.nc
    mf=$tdir/${y}.nc
    [[ $d = land ]] && logic=ifthen || logic=ifnotthen
    CDO $logic $remsk $df $mf
  done
done

hemispheres="global N S"
bands="tropics midlats polar"
echo "### Preparing means .."
tsdir=$ddir/ts
mkdir -p $tsdir
for h in $hemispheres; do
  if [ $h = global ]; then
    hfs=$ddir/{${y1}..${y2}}.nc
    hof=$tsdir/${h}.nc
    echo " .. $h .. "
    eval CDO fldmean -mergetime $hfs $hof

    for d in $domains; do
      hfs=$ddir/$d/{${y1}..${y2}}.nc
      hof=$tsdir/${h}-${d}.nc
      echo " .. $h-$d .. "
      eval CDO fldmean -mergetime $hfs $hof
    done
  else
    for b in $bands; do
      hb=${h}-${b}
      for d in $domains; do
        hbd=${hb}-${d}
        [[ $hb = N-polar   ]] && box="-180,180,60,90"
        [[ $hb = N-midlats ]] && box="-180,180,30,60"
        [[ $hb = N-tropics ]] && box="-180,180,0,30"
        [[ $hb = S-tropics ]] && box="-180,180,-30,0"
        [[ $hb = S-midlats ]] && box="-180,180,-60,-30"
        [[ $hb = S-polar   ]] && box="-180,180,-90,-60"
        hfs=$ddir/$d/{${y1}..${y2}}.nc
        hof=$tsdir/${hbd}.nc
        echo " .. $hbd .. "
        eval CDO fldmean -sellonlatbox,$box -mergetime $hfs $hof
      done
    done
  fi
done

echo "Complete."

}
