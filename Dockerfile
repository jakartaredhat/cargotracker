####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
###
FROM registry.access.redhat.com/ubi8/openjdk-11:latest AS build

USER root
WORKDIR /build
RUN mkdir -p .mvn/wrapper
COPY mvnw /build
COPY .mvn/wrapper .mvn/wrapper
COPY pom.xml /build
COPY src /build/src
RUN ls -R /build

RUN ./mvnw dependency:go-offline

RUN ./mvnw -Pwildfly -DskipTests package
RUN ls -l /build/target/cargo-tracker.war
RUN jar -tf /build/target/cargo-tracker.war
RUN pwd

#FROM jboss/wildfly:23.0.2.Final
FROM quay.io/wildfly/wildfly
USER 0
RUN yum -y install net-tools
COPY --from=build /build/target/cargo-tracker.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080
EXPOSE 9990
EXPOSE 8787

USER 1000
ENV JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,address=*:8787"
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "--debug", "-c", "standalone-full.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
