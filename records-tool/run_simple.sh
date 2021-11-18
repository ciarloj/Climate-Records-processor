#!/bin/bash
{

set -eo pipefail

nlist=$1

./main/year-split.sh $nlist
./main/stats.sh $nlist
./main/records.sh $nlist

}
