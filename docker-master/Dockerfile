# FROM clojure
FROM debian:latest


ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSE_VERSION 1.12.0

RUN apt-get update -q \
      && apt-get install -y -q --no-install-recommends \
      curl ca-certificates \
      build-essential git zlib1g-dev python \
      # docker-compose
      && curl -o /usr/local/bin/docker-compose -L \
      "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64" \
      && chmod +x /usr/local/bin/docker-compose \
      # kafkacat
      && git clone https://github.com/edenhill/kafkacat.git && \
      cd kafkacat && \
      ./bootstrap.sh && \
      make install && \
      cd .. && rm -rf kafkacat
      # && AUTO_ADDED_PACKAGES=`apt-mark showauto` && \
      # apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES && \
      # rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# clojure app
# COPY project.clj /usr/src/app/
# run lein deps
# copy . /usr/src/app
# RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar

# ENTRYPOINT ["kafkacat"]
# CMD ["java", "-jar", "app-standalone.jar"]
