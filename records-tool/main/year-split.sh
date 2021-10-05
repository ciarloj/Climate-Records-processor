#!/bin/bash
{
set -eo pipefail

nlist=$1
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
dd=$( cat $nlist | grep 'd_dir =' | cut -d"'" -f2 )
df=$( cat $nlist | grep 'd_fnm =' | cut -d"'" -f2 )
vv=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )
y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
y_sp=$( cat $nlist | grep 'yr_split =' | cut -d"'" -f2 )
y_tr=$( cat $nlist | grep 'yr_trimm =' | cut -d"'" -f2 )

sf=$dd/$df
hdir=$wkd/$jm/$dn

ydir=$hdir
mkdir -p $ydir
if [ $y_sp = 'true' ]; then
  echo "## Running Year-split."
  for y in $( seq $y1 $y2 ); do
    echo "working on $y.."
    cdo -O -L -f nc4 -z zip selyear,$y $sf $ydir/${y}.nc
    if [ $dn = E_OBS ]; then
      [[ $vv = pr ]] && vo=rr
      [[ $vv = tas ]] && vo=tg
      ncrename -O -v ${vo},$vv $ydir/${y}.nc
      ncap2 -O -s "${vv}=${vv}.float()" $ydir/${y}.nc $ydir/${y}.nc
    fi
  done
  echo "## Year-split done."
  echo ""
fi

if [ $y_tr = 'true' ]; then
  ydir=$hdir/trim
  mkdir -p $ydir
  echo "## Running Trimming."
  for y in $( seq $y1 $y2 ); do
    echo "checking on $y.."
    set +e
    d=$( ncdump -h $ydir/../${y}.nc | grep -i time | head -1 | cut -d'(' -f2 | cut -d' ' -f1 )
    set -e
    if [ $d -ne 365 ]; then
      echo "trimming $y.."
      cdo -O -L -f nc4 -z zip delete,day=29,month=2 $ydir/../${y}.nc $ydir/${y}.nc
    else
      if [ ! -f $ydir/${y}.nc ]; then
        ln -s $ydir/../${y}.nc $ydir/${y}.nc
      fi
    fi
  done
  echo "## Trimming done."
  echo ""
fi
echo "## Year & Trim done."
echo ""

}
