# Readme

A simple Project that views Github public repos

# Installation

---

This project is based on docker for each environment  there is a Dockerfile that contains the binaries for the application for easier deployment

## Development

Development environment is pretty simple by running postgresql and rails app and provides a volume changes and autoloaders
 

### Start

```bash
# for x86 platform
$ docker-compose up --build
# for arm platform
$ docker-compose -f docker-compose.arm.yml up --build
```

`docker/development/Dockerfile`

```bash
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
```

`docker-compose.yml`

```bash
version: "3.7"

services:
  web:
    build:
      context: .
      dockerfile: docker/development/Dockerfile
    volumes:
      - .:/app
    command: /bin/run.sh
    ports:
      - 3000:3000
    depends_on:
      - postgresql
    env_file:
      - .env
  redis:
    image: redis:5.0.1
  postgresql:
    image: postgres:13
    volumes:
      - pg-data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: notsecure
    ports:
      - 5432:5432

volumes:
  pg-data:
```

`.env`

```bash
RAILS_ENV=development
DATABASE_URL=postgres://postgres:notsecure@postgresql:5432/github-pub-repos_development
```

## Production

For production it’s a bit tricky where the environment variables are fetched from aws secrets manager, assuming there is one so for the production image it should be built with AWS IAM secrets, depending on

`config/initializers/aws_secrets.rb`

```ruby
if %w(staging production).include?(ENV['RAILS_ENV']) && ENV['DB_ADAPTER'] != 'nulldb'
  begin
    client = client = Aws::SecretsManager::Client.new(region: ENV.fetch('AWS_REGION', 'eu-north-1'))
    secrets_string = client.get_secret_value(secret_id: "github-pub-repos/#{ENV['RAILS_ENV']}").secret_string
    parsed_secrets = JSON.parse(secrets_string)

    parsed_secrets.each do |env_key, env_value|
      ENV[env_key] = env_value
    end
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException
  end
end
```

`docker/production/Dockerfile`

```bash
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
```

### Build & Push

```ruby
$ docker build -f docker/production/Dockerfile --build-args AWS_ACCESS_KEY_ID="" AWS_SECRET_ACCESS_KEY="" -t github-pub-repos:latest .
```