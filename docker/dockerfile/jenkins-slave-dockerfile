FROM openjdk:8-jre-stretch

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

RUN mkdir -p /usr/share/jenkins
RUN wget -O /usr/share/jenkins/swarm-client.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.13/swarm-client-3.13.jar
RUN chmod -R 755 /usr/share/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
