#!/bin/bash
{

set -eo pipefail

# find all .txt files
txtFiles=$(find . -type f -name "*.txt")

# get domain and scenario command line args
while getopts d:s: flag
do
    case "$flag" in
        d) domain=${OPTARG};;
        s) scenario=${OPTARG};;
    esac
done
#echo "Domain: $domain";
#echo "Scenario: $scenario";


echo "------------ $domain-$scenario ------------"
d=$domain
s=$scenario
for txtFile in $txtFiles ; do
  HR=HADGEM
  LR=NORESM
  mr=MR

  if [[ $txtFile == *$scenario* && $txtFile == *$domain* ]]; then	 
    #echo $txtFile
    #echo $domain-$scenario

    [[ $domain = WAS ]] && HR=MIROC
    [[ $domain = NAM ]] && LR=GFDL
    [[ $domain = CAM ]] && LR=GFDL	
    [[ $domain = EUR ]] && mr=LR
    [[ $domain = NAM ]] && mr=LR
    # for each filtered file, determine which variable to assign
    [[ $txtFile == *"${d}-REGCM-${HR}-${s}"* ]] && R1_HR=$(cat $txtFile)
    [[ $txtFile == *"${d}-REGCM-MPI-${s}"*   ]] && R1_MR=$(cat $txtFile)
    [[ $txtFile == *"${d}-REGCM-${LR}-${s}"* ]] && R1_LR=$(cat $txtFile)
    #same for GCM corresponding to RegCM
#    [[ $txtFile == *"${d}-${HR}-${s}"*    ]] && G1_HR=$(cat $txtFile)
#    [[ $txtFile == *"${d}-MPI${mr}-${s}"* ]] && G1_MR=$(cat $txtFile)
#    [[ $txtFile == *"${d}-${LR}-${s}"*    ]] && G1_LR=$(cat $txtFile)
    #same for REMO
    [[ $txtFile == *"${d}-REMO-HADGEM-${s}"* ]] && R2_HR=$(cat $txtFile)
    [[ $txtFile == *"${d}-REMO-MPI-${s}"*    ]] && R2_MR=$(cat $txtFile)
    [[ $txtFile == *"${d}-REMO-NORESM-${s}"* ]] && R2_LR=$(cat $txtFile)
    #same for GCM corresponding to REMO
#    [[ $txtFile == *"${d}-HADGEM-${s}"* ]] && G2_HR=$(cat $txtFile) 
#    [[ $txtFile == *"${d}-MPILR-${s}"*  ]] && G2_MR=$(cat $txtFile)
#    [[ $txtFile == *"${d}-NORESM-${s}"* ]] && G2_LR=$(cat $txtFile)
  fi
done

if [ $domain = CAS ]; then
  R1_HR="NaN"
  R1_MR="NaN"
  R1_LR="NaN"
  G1_HR="NaN"
  G1_MR="NaN"
  G1_LR="NaN"
elif [ $domain = NAM -a $scenario = 26 ]; then
  R1_HR="NaN"
  R1_MR="NaN"
  R1_LR="NaN"
  G1_HR="NaN"
  G1_MR="NaN"
  G1_LR="NaN"
fi

echo "R1-HR = $R1_HR"
echo "R1-MR = $R1_MR"
echo "R1-LR = $R1_LR"
#echo "G1-HR = $G1_HR"
#echo "G1-MR = $G1_MR"
#echo "G1-LR = $G1_LR"
echo "R2-HR = $R2_HR"
echo "R2-MR = $R2_MR"
echo "R2-LR = $R2_LR"
#echo "G2-HR = $G2_HR"
#echo "G2-MR = $G2_MR"
#echo "G2-LR = $G2_LR"

# save all the R1-HR, R1-MR, R1-LR, ..... in a .txt or .log file for each domain and each scenario
destinationFile=$domain-$scenario.log
echo -e "R1-HR\tR1-MR\tR1-LR\tR2-HR\tR2-MR\tR2-LR" > "$destinationFile"
echo -e "$R1_HR\t$R1_MR\t$R1_LR\t$R2_HR\t$R2_MR\t$R2_LR" >> "$destinationFile"
}
