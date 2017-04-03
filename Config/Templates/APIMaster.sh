#!/bin/bash

echo "Started TAP API mointor agent..." > ${Buildloc}APIoutput.log
echo "###############################" >> ${Buildloc}APIoutput.log
if [ ! -f ${TAP_SHARE_LOC}/api.lck ]
then
        echo "Running" > ${TAP_SHARE_LOC}/api.lck
fi
which java >> ${Buildloc}APIoutput.log
java -version >> ${Buildloc}APIoutput.log
echo "###############################" >> ${Buildloc}APIoutput.log
java -cp /opt/hpe/tap/apiengine/api.jar com.hpe.api.execute ${mainscript} ${Buildloc} >> ${Buildloc}APIoutput.log 2>&1

sleep 10


echo "Finished executing the tests" >> ${Buildloc}APIoutput.log
if [ -f ${TAP_SHARE_LOC}/api.lck ]
then
        rm -f ${TAP_SHARE_LOC}/api.lck
fi 
