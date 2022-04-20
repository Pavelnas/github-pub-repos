#!/bin/sh
bundle exec rails db:exists && rails db:migrate || rails db:setup

bundle exec puma -C config/puma.rb
