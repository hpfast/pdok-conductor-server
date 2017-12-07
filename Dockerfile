# conductor:server - Netflix conductor server
# First checkout the source and build it
#stage 0: build the conductor server jar
FROM azul/zulu-openjdk:8 as builder
RUN apt-get update
RUN apt-get install -y git gradle

#get the source and build it
RUN git clone --branch v1.8.1 https://github.com/Netflix/conductor /src
WORKDIR /src
RUN gradle build
WORKDIR /src/server/build/libs
RUN for i in conductor-*-all.jar; do mv "$i" "`echo $i | sed 's/-SNAPSHOT//'`"; done




#now create a new container with just the artifacts
FROM java:8-jre-alpine
# Make app folders
RUN mkdir -p /app/config /app/logs /app/libs
# Copy the project directly onto the image, from the previous stage
# Copy the files for the server into the app folders
COPY --from=builder /src/docker/server/bin /app
COPY --from=builder /src/docker/server/config /app/config
#override the config
COPY config.properties /app/config/config.properties
COPY --from=builder /src/server/build/libs/conductor-server-*-all.jar /app/libs

RUN chmod +x /app/startup.sh

EXPOSE 8080

CMD [ "/app/startup.sh" ]
ENTRYPOINT [ "/bin/sh"]
