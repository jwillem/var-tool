# docker-var
## Install
Als erstes wird das Projekt mithilfe von `git clone https://github.com/jwillem/var-tool.git` heruntergeladen.
Um die Applikation zu starten, werden zunächst die Installationen von Docker [1] und Docker-Compose [2] benötigt.
Nach einem Ausführen von `docker-compose build` im Projektverzeichnis kann die App mit `docker-compose up` gestartet werden.

[1] https://www.docker.com/community-edition

[2] https://docs.docker.com/compose/install
## Enpoints
- Client: `http://localhost:80/public` or in dev: `http://localhost:80`
- Websocket: `ws://localhost:8080/ws`
- init Session on Server: `http://localhost:8080/hello`
- upload submissions to Server: `http://localhost:8080/experiment/{experimentId}/instance/{instanceId}`

## Build Jars on command-line
- compile: `mkdir build && javac -d build src/var/rmi/chat/*.java`
- build jar: `cd build && jar -cvfe RmiChat.jar var/rmi/chat/ChatServer var/rmi/chat/*.class && cp RmiChat.jar ../ && cd ..`
- run: `java -cp RmiChat.jar var.rmi.chat.ChatServer`, respectively `java -cp RmiChat.jar var.rmi.chat.ChatClient "John Doe"`
