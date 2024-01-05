#!/bin/bash
{
set -eo pipefail

ndir=mynamelists
st="runmax"
nd="30"

export y1=1980
export y2=2020
export var=n

get_records_data(){
  nlist=$1
  wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
  jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
  dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
  echo "Extracting input for $dn .."

  hdir=$wkd/$jm/$dn
  ydir=/trim/${st}-$nd
  export ddir=$ydir/records/sum/
  dnam=index
  export dfil=${dnam}_fld_norm.nc
  din=$hdir/$ddir/$dfil
}

args=''
## ERA 
nlist=$ndir/era5.list
get_records_data $nlist
args=''$args' hd1="'$hdir'"'
#####

export idir=$wkd/$jm/images  ##needed only once
mkdir -p $idir

## MERRA
nlist=$ndir/merra.list
get_records_data $nlist
args=''$args' hd2="'$hdir'"'
#####

## JRA
nlist=$ndir/jra-55.list
get_records_data $nlist
args=''$args' hd3="'$hdir'"'
#####

## MSWEP
nlist=$ndir/mswep.list
get_records_data $nlist
args=''$args' hd4="'$hdir'"'
#####

ncl -Q $args tools/plot_c-fig_1.ncl
ncl -Q $args tools/plot_c-fig_2.ncl

}
