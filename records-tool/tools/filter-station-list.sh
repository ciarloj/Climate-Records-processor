#!/bin/bash
{
set -eo pipefail

in=tools/eobs-stations.txt
out=tools/eobs-italy.txt

cp $in $out

lonmax=20
lonmin=6
latmax=50
latmin=35

c=0
while IFS= read -r line; do
  c=$(( c+1 ))
  [[ $c -lt 20 ]] && continue
  stnn=$( echo $line | cut -d',' -f1 )
  echo -ne "$stnn"\\r
 # echo "$stnn"
  latt=$( echo $line | cut -d',' -f4 )
  latd=$( echo $latt | cut -d':' -f1 | cut -d'+' -f2 )
  latm=$( echo $latt | cut -d':' -f2 )
  lats=$( echo $latt | cut -d':' -f3 )
  lat=$( echo "$latd + ($latm/60) + ($lats/3600)" | bc -l )
  lont=$( echo $line | cut -d',' -f5 )
  lond=$( echo $lont | cut -d':' -f1 | cut -d'+' -f2 )
  lonm=$( echo $lont | cut -d':' -f2 )
  lons=$( echo $lont | cut -d':' -f3 )
  lon=$( echo "$lond + ($lonm/60) + ($lons/3600)" | bc -l )
  
  latmaxif=$((`echo "$lat > $latmax" | bc`))
  latminif=$((`echo "$lat < $latmin" | bc`))
  lonmaxif=$((`echo "$lon > $lonmax" | bc`))
  lonminif=$((`echo "$lon < $lonmin" | bc`))
  [[ $latmaxif -eq 1 ]] && sed -i "/$line/d" "$out" 
  [[ $latminif -eq 1 ]] && sed -i "/$line/d" "$out"
  [[ $lonmaxif -eq 1 ]] && sed -i "/$line/d" "$out"
  [[ $lonminif -eq 1 ]] && sed -i "/$line/d" "$out"

  # echo $stnn : $lat : $lon
  # [[ $c -gt 30 ]] && break
done < "$in"

}
