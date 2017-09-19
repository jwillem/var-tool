FROM clojure

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

# build
RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar
CMD ["java", "-jar", "app-standalone.jar"]
