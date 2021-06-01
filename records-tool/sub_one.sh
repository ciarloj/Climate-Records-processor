#!/bin/bash
# submit script for SLURM
{
set -eo pipefail

task=$1
nlist=$2
dep=$3

em='jciarlo@ictp.it'
pp='esp'
mail='FAIL'
wall='24:00:00'
nn='1'

jm=$( cat $nlist | grep 'job_mst =' | cut -d"'" -f2 )
dn=$( basename $nlist | cut -d'.' -f1 )
wkd=$( cat $nlist | grep 'wrk_dir =' | cut -d"'" -f2 )
ldir=$wkd/$jm/logs
mkdir -p $ldir

tsk=$( basename $task | cut -d'.' -f1 )
j="${jm}_${dn}_${tsk}"
o="$ldir/${j}.o"
e="$ldir/${j}.e"
batch_in="-J $j -o $o -e $e -N $nn -t $wall $dep --mail-type=$mail --mail-user=$em -p $pp"
sbatch $batch_in $dep ./$task $nlist

}
