#!/bin/bash
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

nlist=$1
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
vv=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
set +e
ym=$( cat $nlist | grep 'myr =' | cut -d"'" -f2 )
set -e
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
st=$( cat $nlist | grep 'stat =' | cut -d"'" -f2 )
nd=$( cat $nlist | grep 's_nd =' | cut -d"'" -f2 )
y_sp=$( cat $nlist | grep 'yr_split =' | cut -d"'" -f2 )
y_tr=$( cat $nlist | grep 'yr_trimm =' | cut -d"'" -f2 )
y_st=$( cat $nlist | grep 'yr_stats =' | cut -d"'" -f2 )
y_rc=$( cat $nlist | grep 'yr_recor =' | cut -d"'" -f2 )
y_ts=$( cat $nlist | grep 'yr_tmsum =' | cut -d"'" -f2 )
y_mg=$( cat $nlist | grep 'yr_merge =' | cut -d"'" -f2 )
y_nm=$( cat $nlist | grep 'yr_norma =' | cut -d"'" -f2 )
[[ $st = day ]] && y_st='false'
#[[ $st = monmax ]] && y_tr='false'
[[ $st = monsum ]] && y_tr='false'

if [ -z $ym ]; then
  y_mid='false'
else
  y_mid='true'
fi

v=$vv
hdir=$wkd/$jm/$dn
ydir=$hdir
#if [ $st != monmax -a $st != monsum ]; then
if [ $y_tr = true ]; then
  ydir=$hdir/trim
fi
if [ $st != day ]; then
  sdir=${st}-$nd
  [[ $st = monmax ]] && sdir=$st
  [[ $st = monsum ]] && sdir=$st
  ydir=$ydir/$sdir
fi
rdir=$ydir/records
rfb=$rdir/records_base.nc
#cf=$rdir/count.nc
#cfs=$rdir/count_sum.nc
rf=$rdir/records.nc
if [ $y_rc = true ]; then
  echo "## Preparing base records."
  mkdir -p $rdir
  cp $ydir/${y1}.nc $rfb
  cp $rfb ${rf}_2.nc
  CDO sub $rfb ${rf}_2.nc ${rf}_0.nc
  rm ${rf}_2.nc
  mv ${rf}_0.nc $rfb
  ncrename -O -v $v,max $rfb

 #echo "## Counting points."
 #cdo -O -L -f nc4 -z zip expr,'np=max+1' $rfb $cf
 #cdo -O -L -f nc4 -z zip timsum -fldsum $cf $cfs

  echo "## Running records."
  cp $rfb $rf
  for y in $( seq $y1 $y2 ); do
    echo "Assessing $y .."
    inf=$ydir/${y}.nc
    ouf=$rdir/${y}.nc
    cp $inf $ouf
    ncks -A -v max $rf $ouf
    if [ $y = $y1 ]; then
      cdo -O -L -f nc4 -z zip aexpr,"n=($v >= max)?1:0 ; max=(n==1)?$v:max ; p=$v-$v+1" $ouf ${ouf}_t.nc
    else
      cdo -O -L -f nc4 -z zip aexpr,"n=($v > max)?1:0 ; max=(n==1)?$v:max ; p=$v-$v+1" $ouf ${ouf}_t.nc
    fi
    mv ${ouf}_t.nc $ouf 
    #ncap2 -O -s "n=$v-$v; where($v > max) n=1; where(n==1) max=$v" $ouf $ouf
    CDO selvar,max $ouf $rf
    ncks -A -v time $inf $ouf
  done
  echo "Record assessment complete."
  echo ""
fi

tdir=$rdir/sum
ff=$tdir/index.nc
if [ $y_ts = true ]; then 
  echo "## Summing Records."
  mkdir -p $tdir
  [[ $y_mid = 'true' ]] && y0=$ym || y0=$y1
  for y in $( seq $y0 $y2 ); do
    echo "Summing $y .."
    inf=$rdir/${y}.nc
    ouf=$tdir/${y}.nc
    CDO timsum -selvar,n,p $inf $ouf
    ncatted -O -a units,n,m,c,"#" $ouf
  done
fi 
if [ $y_mg = true ]; then
  echo "## Merging sums."
  eval CDO mergetime $tdir/{${y1}..${y2}}.nc $ff
  echo "Sum complete."
  echo ""
fi

fff=$tdir/index_fld.nc
ffn=$tdir/index_fld_norm.nc
if [ $y_nm = true ]; then
  echo "## Normalising Records."
 #np=$( ncdump -v np $cfs | tail -2 | head -1 | cut -d' ' -f3 )
  CDO fldsum $ff $fff
  CDO chname,nn,n -selvar,nn -aexpr,"nn=n/p" $fff $ffn
 #cdo -O -L -f nc4 -z zip divc,$np $fff $ffn
  echo "Normalising complete."
  echo ""
fi

echo "## Records done."
echo ""

}
