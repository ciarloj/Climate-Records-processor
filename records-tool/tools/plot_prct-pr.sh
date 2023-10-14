#!/bin/bash
{
set -eo pipefail

nlist=$1
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
export dn=$( cat $nlist | grep 'd_nam =' | cut -d"'" -f2 )
export y1=$( cat $nlist | grep 'fyr =' | cut -d"'" -f2 )
export y2=$( cat $nlist | grep 'lyr =' | cut -d"'" -f2 )
v=$( cat $nlist | grep 'var =' | cut -d"'" -f2 )

export pp=99
export var=$v
hdir=$wkd/$jm/$dn
export ddir=$hdir/p$pp/days/ts

export idir=$wkd/$jm/images
mkdir -p $idir

ncl -Q tools/plot_prct-pr.ncl

}
