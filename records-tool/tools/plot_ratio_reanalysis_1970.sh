#!/bin/bash
{	
set -eo pipefail

dom=EUR
ndir=/home/netapp-clima-scratch/lbelleri/records-tool/mynamelists
if [ $dom = CAS -o $dom = SAM -o $dom = AFR -o $dom = AUS ]; then
  echo "ERROR. Script does not work for $dom"
  exit 1
fi

tslice=N #Y or N
[[ $tslice = Y ]] && tper=1970-2020
st="runmax"
nd="30"

get_records_data(){
  nlist=$1
  wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
  jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
  dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
  y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
  y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
  echo "Extracting input for $dn .."

  yo1=$y1
  yo2=$y2
  if [ $tslice = Y ]; then
    y1a=$( echo $tper | cut -d'-' -f1 )
    y2a=$( echo $tper | cut -d'-' -f2 )
    c=0
    for n in $( seq $y1 $y1a ); do
      n1=$c
      c=$((c+1))
    done
    n2=$(( $y2a - $y1 ))
    y1=$y1a
    y2=$y2a
  else
    n1=0
    n2=$(( $y2 - $y1 ))
  fi

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
  else
    sdir=day
  fi
  ddir=$ydir/records/sum
  dnam=index
  din=$ddir/${dnam}_fld_norm.nc
}

nmod=3

idir=$wkd/$jm/images  ##needed only once
idir="/home/netapp-clima-scratch/lbelleri/records/images/"
mkdir -p $idir

export idir=$idir
export stat=$sdir
export nmod=$nmod
export dom=$dom

## OBS
#[[ $dom = EUR ]] && obn=e-obs
#[[ $dom = NAM ]] && obn=namerext_nam
#[[ $dom = CAM ]] && obn=namerext_cam
#[[ $dom = EAS ]] && obn=aphro_ma_eas
#[[ $dom = SEA ]] && obn=aphro_ma_sea
#[[ $dom = WAS ]] && obn=imd


#export obsn=${obn^^}
#nlist=$ndir/${obn}.list
get_records_data $nlist
export fno0=$din
export yr1o0=$y1
export yr2o0=$y2
export dno0=$dn
export n1o0=$n1
export n2o0=$n2
export yo1o0=$yo1
export yo2o0=$yo2


#[[ $dom = NAM ]] && obn=namerext_nam 
#export obsn=${obn^^}
#nlist=$ndir/${obn}.list
#get_records_data $nlist
#export fno0=$din
#export yr1o0=$y1
#export yr2o0=$y2
#export dno0=$dn
#export n1o0=$n1
#export n2o0=$n2
#export yo1o0=$yo1
#export yo2o0=$yo2


#[[ $dom = CAM ]] && obn=namerext_cam 
#export obsn=${obn^^}
#nlist=$ndir/${obn}.list
#get_records_data $nlist
#export fno0=$din
#export yr1o0=$y1
#export yr2o0=$y2
#export dno0=$dn
#export n1o0=$n1
#export n2o0=$n2
#export yo1o0=$yo1
#export yo2o0=$yo2

## ERA 
nlist=$ndir/${dom~~}_era5.list
get_records_data $nlist

args=''$args' fnr1="'$din'" yr1r1="'$y1'" yr2r1="'$y2'" dnr1="'$dn'" n1r1="'$n1'" n2r1="'$n2'" yo1r1="'$yo1'" yo2r1="'$yo2'"'
#####

## MERRA
nlist=$ndir/${dom~~}_merra.list
get_records_data $nlist

args=''$args' fnr2="'$din'" yr1r2="'$y1'" yr2r2="'$y2'" dnr2="'$dn'" n1r2="'$n1'" n2r2="'$n2'" yo1r2="'$yo1'" yo2r2="'$yo2'"'
#####

## JRA
nlist=$ndir/${dom~~}_jra55.list
get_records_data $nlist

args=''$args' fng1="'$din'" yr1g1="'$y1'" yr2g1="'$y2'" dng1="'$dn'" n1g1="'$n1'" n2g1="'$n2'" yo1g1="'$yo1'" yo2g1="'$yo2'"'
#####


ncl -Q $args tools/plot_ratio_reanalysis_masked.ncl

}
