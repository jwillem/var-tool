# docker-var
## Install

## Build Jars on command-line
- compile: `mkdir build && javac -d build src/var/rmi/chat/*.java`
- build jar: `cd build && jar -cvfe RmiChat.jar var/rmi/chat/ChatServer var/rmi/chat/*.class && cp RmiChat.jar ../ && cd ..`
- run: `java -cp RmiChat.jar var.rmi.chat.ChatServer`, respectively `java -cp RmiChat.jar var.rmi.chat.ChatClient "John Doe"`
