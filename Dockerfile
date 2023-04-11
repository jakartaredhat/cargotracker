####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
###
FROM registry.access.redhat.com/ubi8/openjdk-11:latest AS build

USER root
WORKDIR /build
RUN mkdir -p .mvn/wrapper
COPY mvnw .
COPY .mvn/wrapper .mvn/wrapper
COPY pom.xml .
COPY src .

RUN ./mvnw dependency:go-offline

RUN ./mvnw -Pwildfly -DskipTests package
RUN ls
RUN pwd

FROM jboss/wildfly:23.0.2.Final

COPY --from=build /build/target/cargo-tracker.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080
USER 1000

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-c", "standalone-full.xml", "-b", "0.0.0.0"]
