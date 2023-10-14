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
[[ $st = day ]] && y_st='false'
#[[ $st = monmax ]] && y_tr='false'
[[ $st = monsum ]] && y_tr='false'

hdir=$wkd/$jm/$dn
ydir=$hdir
[[ $y_tr = true ]] && ydir=$hdir/trim
if [ $y_st = true ]; then
  sdir=${st}-$nd
  [[ $st = monmax ]] && sdir=$st
  [[ $st = monsum ]] && sdir=$st
  echo "## Running Stat for $sdir."
  odir=$ydir/$sdir
  mkdir -p $odir
  for f in $( eval ls $ydir/{${y1}..${y2}}.nc ); do
    echo "working on $( basename $f | cut -d'.' -f1 ).."
    of=$odir/$( basename $f )
    if [ $st = 'monmax' -o $st = 'monsum' ]; then
      cdo -O -L -f nc4 -z zip $st $f $of
    else
      cdo -O -L -f nc4 -z zip $st,$nd $f $of
    fi
  done
else
  echo "## Statistics processing not required."
fi
echo "## Stat done."
echo ""

}
