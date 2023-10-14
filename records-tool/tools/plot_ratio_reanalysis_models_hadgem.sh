#!/bin/bash
{
set -eo pipefail

dom=EAS
ndir=/home/netapp-clima-scratch/lbelleri/records-tool/mynamelists
#if [ $dom = CAS -o $dom = SAM -o $dom = AFR -o $dom = AUS ]; then
#  echo "ERROR. Script does not work for $dom"
#  exit 1
#fi

tslice=N #Y or N
[[ $tslice = Y ]] && tper=1980-2020
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

nmod=7

idir=$wkd/$jm/images  ##needed only once
idir="/home/netapp-clima-scratch/lbelleri/records/images/"
mkdir -p $idir

export idir=$idir
export nmod=$nmod
export dom=$dom

## OBS
[[ $dom = EUR ]] && obn=e-obs
[[ $dom = NAM ]] && obn=namerext_nam
[[ $dom = CAM ]] && obn=namerext_cam
[[ $dom = SAM ]] && obn=namerext_cam
[[ $dom = AUS ]] && obn=namerext_cam
[[ $dom = AFR ]] && obn=aphro_me
[[ $dom = EAS ]] && obn=aphro_ma_eas
[[ $dom = SEA ]] && obn=aphro_ma_sea
[[ $dom = WAS ]] && obn=imd


export obsn=${obn^^}
nlist=$ndir/${obn}.list
get_records_data $nlist 
export stat=$sdir

export fno0=$din ; export yr1o0=$y1 ; export yr2o0=$y2 ; export dno0=$dn ; export n1o0=$n1 ; export n2o0=$n2 ; export yo1o0=$yo1 ; export yo2o0=$yo2

## ERA 
echo "ERA with y1 = $y1"
nlist=$ndir/${dom~~}_era5.list
get_records_data $nlist 
args=''$args' fnr1="'$din'" yr1r1="'$y1'" yr2r1="'$y2'" dnr1="'$dn'" n1r1="'$n1'" n2r1="'$n2'" yo1r1="'$yo1'" yo2r1="'$yo2'"'
#####

## MERRA
echo "MERRA with y1 = $y1"
nlist=$ndir/${dom~~}_merra.list
get_records_data $nlist 
args=''$args' fnr2="'$din'" yr1r2="'$y1'" yr2r2="'$y2'" dnr2="'$dn'" n1r2="'$n1'" n2r2="'$n2'" yo1r2="'$yo1'" yo2r2="'$yo2'"'
#####

## JRA
echo "JRA with y1 = $y1"
nlist=$ndir/${dom~~}_jra55.list
get_records_data $nlist 
args=''$args' fnr3="'$din'" yr1r3="'$y1'" yr2r3="'$y2'" dnr3="'$dn'" n1r3="'$n1'" n2r3="'$n2'" yo1r3="'$yo1'" yo2r3="'$yo2'"'
#####

export mod1id=5    #number id to identify the frist model (as opposed to obs or reanalysis)
export cutoff=2020 #cut off year for analysis
get_cutoff_year(){
  yc=$1
  c=0
  for n in $( seq $y1 $yc ); do
    nc=$c
    c=$((c+1))
  done
}

## HADGEM
echo "MPI with y1 = $y1"
nlist=$ndir/${dom~~}_hadgem_26.list
get_records_data $nlist
get_cutoff_year $cutoff
args=''$args' fnm1="'$din'" yr1m1="'$y1'" yr2m1="'$y2'" dnm1="'$dn'" n1m1="'$n1'" n2m1="'$n2'" yo1m1="'$yo1'" yo2m1="'$yo2'" com1="'$nc'"'

## REGCM HADGEM
echo "REGCM MPI with y1 = $y1"
nlist=$ndir/${dom~~}_remo_hadgem_26.list
get_records_data $nlist
get_cutoff_year $cutoff
args=''$args' fnm2="'$din'" yr1m2="'$y1'" yr2m2="'$y2'" dnm2="'$dn'" n1m2="'$n1'" n2m2="'$n2'" yo1m2="'$yo1'" yo2m2="'$yo2'" com2="'$nc'"'

## REMO HADGEM
echo "REMO MPI with y1 = $y1"
nlist=$ndir/${dom~~}_regcm_hadgem_26.list
get_records_data $nlist
get_cutoff_year $cutoff
args=''$args' fnm3="'$din'" yr1m3="'$y1'" yr2m3="'$y2'" dnm3="'$dn'" n1m3="'$n1'" n2m3="'$n2'" yo1m3="'$yo1'" yo2m3="'$yo2'" com3="'$nc'"'



ncl -Q $args tools/plot_ratio_reanalysis_models_hadgem.ncl

}
