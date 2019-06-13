#!/bin/bash
#cd /var/www/railswiki/
export SECRET_KEY_BASE="bundle exec rake secret"
bundle exec rails unicorn:start
