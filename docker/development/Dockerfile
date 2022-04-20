FROM ruby:2.5.8

RUN apt-get update &&  apt-get install -y \
      build-essential \
      postgresql-client \
      imagemagick \
      netcat \
      git-core \
      && apt-get autoremove \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v '= 2.2.30'
RUN bundle install --jobs 20 --retry 5

# install webpacker packages
COPY package.json ./
RUN npm install -g yarn
RUN yarn install

COPY docker/run.sh /bin/run.sh

RUN chmod +x /bin/run.sh

COPY . .
