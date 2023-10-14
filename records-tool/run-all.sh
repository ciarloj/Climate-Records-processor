#!/bin/bash
{

set -eo pipefail
# save as run-all.sh

fileNames="nam_noresm_85 eur_remo_noresm_85"

for fileName in $fileNames; do
  fullName="mynamelists/$fileName.list"
  echo "Launching run.sh $fullName"
  ./run.sh $fullName
done

}
