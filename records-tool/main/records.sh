#!/bin/bash
{
set -eo pipefail

nlist=$1
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
vv=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
st=$( cat $nlist | grep 'stat =' | cut -d"'" -f2 )
nd=$( cat $nlist | grep 's_nd =' | cut -d"'" -f2 )
y_sp=$( cat $nlist | grep 'yr_split =' | cut -d"'" -f2 )
y_tr=$( cat $nlist | grep 'yr_trimm =' | cut -d"'" -f2 )
y_st=$( cat $nlist | grep 'yr_stats =' | cut -d"'" -f2 )
y_rc=$( cat $nlist | grep 'yr_recor =' | cut -d"'" -f2 )
y_ts=$( cat $nlist | grep 'yr_tmsum =' | cut -d"'" -f2 )
y_nm=$( cat $nlist | grep 'yr_norma =' | cut -d"'" -f2 )
[[ $st = day ]] && y_st='false'
[[ $st = monmax ]] && y_tr='false'
[[ $st = monsum ]] && y_tr='false'

if [ $y_rc = true -o $y_ts = true -o $y_nm = true ]; then
  y_rc='true'
  y_ts='true'
  y_nm='true'
fi

v=$vv
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
fi
if [ $y_rc = true ]; then
  echo "## Preparing base records."
  rdir=$ydir/records
  mkdir -p $rdir
  rfb=$rdir/records_base.nc
  cp $ydir/${y1}.nc $rfb
  ncap2 -O -s "max=$v-$v" $rfb $rfb
  ncks -O -v max $rfb $rfb

  echo "## Counting points."
  cf=$rdir/count.nc
  ncap2 -O -s "np=max+1" $rfb $cf
  cfs=$rdir/count_sum.nc
  cdo -O -L -f nc4 -z zip timsum -fldsum $cf $cfs

  echo "## Running records."
  rf=$rdir/records.nc
  cp $rfb $rf
  for y in $( seq $y1 $y2 ); do
    echo "Assessing $y .."
    inf=$ydir/${y}.nc
    ouf=$rdir/${y}.nc
    cp $inf $ouf
    ncks -A -v max $rf $ouf
    ncap2 -O -s "n=$v-$v; where($v > max) n=1; where(n==1) max=$v" $ouf $ouf
    cdo -O -L -f nc4 -z zip selvar,max $ouf $rf
    ncks -A -v time $inf $ouf
  done
  echo "Record assessment complete."
  echo ""
fi

if [ $y_ts = true ]; then 
  echo "## Summing Records."
  tdir=$rdir/sum
  mkdir -p $tdir
  for y in $( seq $y1 $y2 ); do
    echo "Summing $y .."
    inf=$rdir/${y}.nc
    ouf=$tdir/${y}.nc
    cdo -O -L -f nc4 -z zip timsum -selvar,n $inf $ouf
    ncatted -O -a units,n,m,c,"#" $ouf
  done
  echo "## Merging sums."
  ff=$tdir/index.nc
  cdo -O -L -f nc4 -z zip mergetime $tdir/{${y1}..${y2}}.nc $ff
  echo "Sum complete."
  echo ""
fi

if [ $y_nm = true ]; then
  echo "## Normalising Records."
  np=$( ncdump -v np $cfs | tail -2 | head -1 | cut -d' ' -f3 )
  fff=$tdir/index_fld.nc
  ffn=$tdir/index_fld_norm.nc
  cdo -O -L -f nc4 -z zip fldsum $ff $fff
  cdo -O -L -f nc4 -z zip divc,$np $fff $ffn
  echo "Normalising complete."
  echo ""
fi

echo "## Records done."
echo ""

}
