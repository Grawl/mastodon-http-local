#!/bin/bash
cd $(dirname ${BASH_SOURCE})
BASE=${1:-mastodondevelopment}

sed -i -e "s|force_ssl|# force_ssl|g" $BASE/app/controllers/application_controller.rb

sed -i -e 's|"https://#{record.domain}"|"http://#{record.domain}"|g' $BASE/app/helpers/admin/action_logs_helper.rb
sed -i -e "s|https://#{attributes['domain']}|http://#{attributes['domain']}|g" $BASE/app/helpers/admin/action_logs_helper.rb

sed -i -e "s|https =|https = false # https =|g" $BASE/config/initializers/1_hosts.rb
sed -i -e "s|http#{Rails.configuration.x.use_https ? 's' : ''}|http|g" $BASE/config/initializers/content_security_policy.rb

sed -i -e "s|https://#{domain}|http://#{domain}|g" $BASE/lib/mastodon/domains_cli.rb

sed -i -e "s|'https'|'http'|g" $BASE/vendor/bundle/ruby/2.6.0/gems/goldfinger-2.1.0/lib/goldfinger/client.rb

sed -i -e "s|Rails.env.production?|false|g" $BASE/app/controllers/application_controller.rb

sed -i -e 's/Rails.env.production? || /false \&\& /g' $BASE/config/initializers/devise.rb
sed -i -e 's/Rails.env.production? || /false \&\& /g' $BASE/config/initializers/session_store.rb
sed -i -e 's/Rails.env.production? || /false \&\& /g' $BASE/config/initializers/1_hosts.rb

# avoid nginx error
sed -i -e "s|config.action_dispatch.x_sendfile_header|# config.action_dispatch.x_sendfile_header|g" $BASE/config/environments/production.rb
