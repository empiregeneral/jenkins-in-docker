#!/usr/bin/bash -xe

# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

# Usage jenkins-agent [options] -url http://jenkins [SECRET] [AGENT_NAME]
# Optional environment variables :
# * JENKINS_TUNNEL : HOST:PORT for a tunnel to route TCP traffic to jenkins host, when jenkins can't be directly accessed over network
# * JENKINS_URL : alternate jenkins URL
# * JENKINS_SECRET : agent secret, if not set as an argument
# * JENKINS_AGENT_NAME : agent name, if not set as an argument

/usr/local/bin/wrapdocker &

#DOCKER_IMAGES_LIST="/home/jenkins/docker_images.txt"
#LINES=`wc -l ${DOCKER_IMAGES_LIST} | tee | awk '{print $1}'`
#if [ -f "${DOCKER_IMAGES_LIST}" ] && [ "${LINES}" -gt 0 ]
#then
#  cat ${DOCKER_IMAGES_LIST} | sed -e "s;^;docker pull ;g"  -e "s;$; --disable-content-trust;g" | bash -xe
#fi

if [ $# -eq 1 ]; then

	# if `docker run` only has one arguments, we assume user is running alternate command like `bash` to inspect the image
	exec "$@"

else

	# if -tunnel is not provided try env vars
	if [[ "$@" != *"-tunnel "* ]]; then
		if [ ! -z "$JENKINS_TUNNEL" ]; then
			TUNNEL="-tunnel $JENKINS_TUNNEL"
		fi
	fi

	if [ -n "$JENKINS_URL" ]; then
		URL="-url $JENKINS_URL"
	fi

	if [ -n "$JENKINS_NAME" ]; then
		JENKINS_AGENT_NAME="$JENKINS_NAME"
	fi

	if [ -z "$JNLP_PROTOCOL_OPTS" ]; then
		echo "Warning: JnlpProtocol3 is disabled by default, use JNLP_PROTOCOL_OPTS to alter the behavior"
		JNLP_PROTOCOL_OPTS="-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=true"
	fi

	sleep 20

	exec java $JAVA_OPTS $JNLP_PROTOCOL_OPTS -cp /home/jenkins/agent.jar hudson.remoting.jnlp.Main -headless $TUNNEL $URL $JENKINS_SECRET $JENKINS_AGENT_NAME "$@"
fi
