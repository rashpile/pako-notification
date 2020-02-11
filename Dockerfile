FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java11 AS build

ENV HOME=/app
USER root
RUN mkdir -p $HOME
RUN chown -R quarkus /app
USER quarkus
WORKDIR $HOME
ADD pom.xml $HOME
# downloading dependencies
#RUN ["mvn", "verify", "clean", "--fail-never"]
#dependency:go-offline
#
RUN ["mvn", "dependency:go-offline"]

ADD src $HOME/src

RUN mvn -f $HOME/pom.xml clean package -Pnative

FROM registry.access.redhat.com/ubi8/ubi-minimal
WORKDIR /work/
COPY --from=build /app/target/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]