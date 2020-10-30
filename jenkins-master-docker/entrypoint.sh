#! /bin/bash -xe

#chown -R 502:20 "${JENKINS_HOME}"

if [ "$#" -eq 0 ]
then
   exec gosu jenkins /bin/tini -- /usr/local/bin/jenkins.sh
else 
   exec $@
fi

