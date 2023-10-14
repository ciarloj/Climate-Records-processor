#!/bin/bash
{
set -eo pipefail

dom=EUR
gcm=MPI
rcp=85
ndir=mynamelists
if [ $dom = CAS ]; then
  echo "Script does not cater for CAS!"
  exit 1
fi

tslice=Y #Y or N
[[ $tslice = Y ]] && tper=1971-2020
st="runmax"
nd="30"
rel="false"
msl="false"

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
  if [ $rel = 'true' -a $msl = 'true' ]; then
    dnam=index_remap_mask
  elif [ $rel = 'true' -a $msl = 'false' ]; then
    dnam=index_remap
  elif [ $rel = 'false' -a $msl = 'true' ]; then
    echo "ERROR! remap = false + mask = true"
    exit 1
  else
    dnam=index
  fi
  din=$ddir/${dnam}_fld_norm.nc
}

nmod=3
[ $dom = WAS -a $gcm = HADGEM ] && nmod=4

## REGCM 
ogcm=$gcm
igcm=$gcm
[ $dom = WAS -a $gcm = HADGEM ] && igcm=MIROC
[ $dom = NAM -a $gcm = NORESM ] && igcm=GFDL
[ $dom = CAM -a $gcm = NORESM ] && igcm=GFDL
if [ $dom = NAM -a $rcp = 26 ]; then
  nlist=$ndir/${dom~~}_regcm_${igcm~~}_85.list
else
  nlist=$ndir/${dom~~}_regcm_${igcm~~}_${rcp}.list
fi
get_records_data $nlist

idir=$wkd/$jm/images  ##needed only once
mkdir -p $idir

args='idir="'$idir'" stat="'$sdir'" nmod="'$nmod'" dom="'$dom'" ogcm="'$ogcm'" rcp="'$rcp'"'
args=''$args' fnr1="'$din'" yr1r1="'$y1'" yr2r1="'$y2'" dnr1="'$dn'" n1r1="'$n1'" n2r1="'$n2'" yo1r1="'$yo1'" yo2r1="'$yo2'"'
#####

## REMO
nlist=$ndir/${dom~~}_remo_${gcm~~}_${rcp}.list
get_records_data $nlist

args=''$args' fnr2="'$din'" yr1r2="'$y1'" yr2r2="'$y2'" dnr2="'$dn'" n1r2="'$n1'" n2r2="'$n2'" yo1r2="'$yo1'" yo2r2="'$yo2'"'
#####

## driving GCM 1
[ $gcm = MPI ] && igcm=MPIMR
[ $dom = NAM -a $gcm = MPI ] && igcm=MPILR
[ $dom = EUR -a $gcm = MPI ] && igcm=MPILR
nlist=$ndir/${dom~~}_${igcm~~}_${rcp}.list
get_records_data $nlist

args=''$args' fng1="'$din'" yr1g1="'$y1'" yr2g1="'$y2'" dng1="'$dn'" n1g1="'$n1'" n2g1="'$n2'" yo1g1="'$yo1'" yo2g1="'$yo2'"'
#####

if [ $nmod = 4 ]; then
  ## driving GCM 2
  [ $gcm = MPI ] && gcm=MPILR
  nlist=$ndir/${dom~~}_${gcm~~}_${rcp}.list
  get_records_data $nlist

  args=''$args' fng2="'$din'" yr1g2="'$y1'" yr2g2="'$y2'" dng2="'$dn'" n1g2="'$n1'" n2g2="'$n2'" yo1g2="'$yo1'" yo2g2="'$yo2'"'
  #####
else
  args=''$args' fng2="n" yr1g2="n" yr2g2="n" dng2="n" n1g2="n" n2g2="n" yo1g2="n" yo2g2="n"'
fi

ncl -Q $args tools/plot_ratio_groups.ncl

}
