FROM nginx

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -q \
      && apt-get install -y -q --no-install-recommends \
      apt-transport-https \
      curl ca-certificates \
      gnupg2 \
      git \
      build-essential

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get remove cmdtest
RUN apt-get update
RUN apt-get install -y yarn

# node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs python

# mount
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app

# build
RUN yarn install
RUN yarn run prod

# bind to nginx dir
RUN rm -r /usr/share/nginx/html
RUN ln -s /usr/src/app/public /usr/share/nginx/html
