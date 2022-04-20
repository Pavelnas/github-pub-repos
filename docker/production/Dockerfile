FROM ruby:2.5.8

ENV RAILS_ENV production
# Arguments passed from builder
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
# save them as perminent environment variables
ENV AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY

RUN apt-get update &&  apt-get install -y \
      build-essential \
      postgresql-client \
      imagemagick \
      netcat \
      nano less tzdata \
      nodejs npm \
      libxml2 libxml2-dev \
      git-core \
      && apt-get autoremove \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v '= 2.2.14'
RUN bundle config set --local without 'development test'
RUN bundle install --jobs 20 --retry 5

# install webpacker packages
COPY package.json ./
RUN npm install -g yarn
RUN yarn install

COPY docker/run.sh /bin/run.sh

RUN chmod +x /bin/run.sh

COPY . .

CMD /bin/run.sh
