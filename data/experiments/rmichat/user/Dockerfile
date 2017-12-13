FROM openjdk:8

ARG INSTANCE_ID
ARG FILE

RUN mkdir -p /app/data
WORKDIR /app

# Copy uploaded File
COPY ${FILE} /app/data/${FILE}
