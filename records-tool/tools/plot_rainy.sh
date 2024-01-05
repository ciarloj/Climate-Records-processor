#!/bin/bash
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

nlist=$1

wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
export dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
export y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
export y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
v=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )

export pp=95
export var=$v
export hdir=$wkd/$jm/$dn
#export ddir=rainy/p$pp/$stat
#export mdir=$hdir/$ddir/merge
#mkdir -p $mdir

merge(){
  dd=$1 ; stat=$2
  [[ $dd = global ]] && dd=""
  echo "merging $dn$dd ..."
  export ddir=rainy/p$pp/$stat
  export tdir=$hdir$dd/$ddir/merge
  mkdir -p $tdir
  tf=$tdir/mergetime.nc
  set +e 
  [[ ! -f $tf ]] && CDO fldmean -mergetime $( eval ls $tdir/../????.nc ) $tf
  set -e
}

domains="land ocean"
[[ $dn = CPC ]] && domains="land"
hemispheres="N S"
bands="tropics midlats polar"

export idir=$wkd/$jm/images
mkdir -p $idir

stats="ndayfR$pp  ndayR$pp  ndayRm$pp  ndaytot R$pp  Rf$pp  Rm$pp  Rtot"
for st in $stats ; do
  export stat=$st
  echo "## Plotting for $stat"

  for d in $domains; do
    merge "-$d" $st
    for h in $hemispheres; do
      for b in $bands; do
        merge "-$h-$b-$d" $st
      done #bands
    done #hemispheres
  done #domains
  merge "global" $st
  ncl -Q tools/plot_rainy.ncl  
done #stats


}
