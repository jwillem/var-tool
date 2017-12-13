FROM clojure

ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSE_VERSION 1.12.0

RUN apt-get update -q \
      && apt-get install -y -q --no-install-recommends \
      curl ca-certificates \
      software-properties-common \
      apt-transport-https \
      build-essential git zlib1g-dev python \
      # envsubst
      gettext 

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian/ stretch stable"
RUN apt-get update -q \
    && apt-get install -y -q docker-ce

# docker-compose
RUN curl -o /usr/local/bin/docker-compose -L \
      "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64" \
      && chmod +x /usr/local/bin/docker-compose

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

# build
RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar
CMD ["java", "-jar", "app-standalone.jar"]
