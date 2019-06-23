FROM jenkins/jenkins:lts

EXPOSE 8080
EXPOSE 50000

RUN /bin/bash -x -c "/usr/local/bin/install-plugins.sh swarm nodelabelparameter"

USER jenkins
VOLUME /home/jenkins