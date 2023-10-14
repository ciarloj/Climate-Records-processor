#!/bin/bash
{

set -eo pipefail

nlist=$1
echo "## namelist = $nlist "

./main/year-split.sh $nlist
./main/stats.sh $nlist
./main/records.sh $nlist

}
