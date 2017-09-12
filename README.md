# docker-var
## Install

## Enpoints
- Client: `http://localhost:80/public` or in dev: `http://localhost:8080`
- Kafka-Websocket: `ws://localhost:7080/v2/broker/?topics=${topic}`

## Build Jars on command-line
- compile: `mkdir build && javac -d build src/var/rmi/chat/*.java`
- build jar: `cd build && jar -cvfe RmiChat.jar var/rmi/chat/ChatServer var/rmi/chat/*.class && cp RmiChat.jar ../ && cd ..`
- run: `java -cp RmiChat.jar var.rmi.chat.ChatServer`, respectively `java -cp RmiChat.jar var.rmi.chat.ChatClient "John Doe"`
