#!/bin/bash
{

set -eo pipefail

#script for each combination of domain and scenario
# AFR
./execute-REGCM-REMO_log.sh -d AFR -s 85
./execute-REGCM-REMO_log.sh -d AFR -s 26
# EUR
./execute-REGCM-REMO_log.sh -d EUR -s 85
./execute-REGCM-REMO_log.sh -d EUR -s 26
# NAM
./execute-REGCM-REMO_log.sh -d NAM -s 85
./execute-REGCM-REMO_log.sh -d NAM -s 26
# CAM
./execute-REGCM-REMO_log.sh -d CAM -s 85
./execute-REGCM-REMO_log.sh -d CAM -s 26
# SAM
./execute-REGCM-REMO_log.sh -d SAM -s 85
./execute-REGCM-REMO_log.sh -d SAM -s 26
# EAS
./execute-REGCM-REMO_log.sh -d EAS -s 85
./execute-REGCM-REMO_log.sh -d EAS -s 26
# SEA
./execute-REGCM-REMO_log.sh -d SEA -s 85
./execute-REGCM-REMO_log.sh -d SEA -s 26
# WAS
./execute-REGCM-REMO_log.sh -d WAS -s 85
./execute-REGCM-REMO_log.sh -d WAS -s 26
# CAS
./execute-REGCM-REMO_log.sh -d CAS -s 85
./execute-REGCM-REMO_log.sh -d CAS -s 26
# AUS
./execute-REGCM-REMO_log.sh -d AUS -s 85
./execute-REGCM-REMO_log.sh -d AUS -s 26


}
