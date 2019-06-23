#!/bin/bash

# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then

  # jenkins swarm slave
  JAR="/usr/share/jenkins/swarm-client.jar"

  echo "Executing java -jar ..."
  exec java -jar $JAR "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"