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

RUN ./mvnw -Ppayara package
RUN ls
RUN pwd

FROM payara/server-full:5.2022.4

#COPY --from=build target/postgresql.jar /tmp
COPY --from=build /build/target/cargo-tracker.war /tmp
COPY post-boot-commands.asadmin /opt/payara/config/
