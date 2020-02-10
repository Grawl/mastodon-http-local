#!/bin/bash
set -e

DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

if [[ -z ${INSTANCE} ]];then
  exit
fi
if [[ -z ${MSTDN_SUBNET} ]];then
  exit
fi
if [[ -z ${MSTDN_IPV4_WEB} ]];then
  exit
fi
if [[ -z ${MSTDN_IPV4_STREAMING} ]];then
  exit
fi
if [[ -z ${MSTDN_IPV4_SIDEKIQ} ]];then
  exit
fi
if [[ -z ${NGINX_IP} ]];then
  exit
fi
if [[ -z ${USER_NAME} ]];then
  exit
fi
if [[ -z ${USER_EMAIL} ]];then
  exit
fi

rm .env
rm .env.development
rm .env.production
rm docker-compose.override.yml

cp ../template/docker-compose.yml ./docker-compose.override.yml
ENV_TEXT=`cat << _EOF_ > .env
MSTDN_SUBNET=${MSTDN_SUBNET}
MSTDN_IPV4_WEB=${MSTDN_IPV4_WEB}
MSTDN_IPV4_STREAMING=${MSTDN_IPV4_STREAMING}
MSTDN_IPV4_SIDEKIQ=${MSTDN_IPV4_SIDEKIQ}
INSTANCE=${INSTANCE}
NGINX_IP=${NGINX_IP}
_EOF_
`
cp ../template/.env.development .

if [[ -n ${PRIVATE_DOMAIN_OR_IP} ]];then
  echo "LOCAL_DOMAIN=${PRIVATE_DOMAIN_OR_IP}" >> .env.development
else
  echo "LOCAL_DOMAIN=${NGINX_IP}" >> .env.development
fi

cp .env.production.sample .env.production

# Comment out pull command if build in local.
#echo 'pull'
docker-compose pull
docker-compose build
#docker-compose run --rm -u root web bundle install
echo 'set keys'
echo -n "SECRET_KEY_BASE=" >> .env.development
#docker-compose run --rm web bash
docker-compose run --rm web bundle exec rake secret >> .env.development
echo -n "OTP_SECRET=" >> .env.development
docker-compose run --rm web bundle exec rake secret >> .env.development

echo 'migrate'
docker-compose run --rm web rails db:migrate
#docker-compose run --rm -u root web sh -c "groupadd docker && chown -R :docker /opt/mastodon && chmod g+rwx /opt/mastodon && rails assets:precompile"
echo 'precompile assets'
docker-compose run --rm web rails assets:precompile
echo 'create user'
echo ${USER_EMAIL} > ../account-${INSTANCE}-${USER_NAME}.md
docker-compose run --rm web bin/tootctl accounts create ${USER_NAME} --email ${USER_EMAIL} --confirmed --role admin >> ../account-${INSTANCE}-${USER_NAME}.md
echo 'swarm up'
docker-compose up -d
echo 'fix permissions'
docker-compose exec -u root web chown -hR mastodon public
