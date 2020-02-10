#!/bin/bash
set -e

DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

# There is a list of reserved user names you cannot use
# https://github.com/tootsuite/mastodon/commit/f7a30e2fae3199a82e2ad23bb9d761d1fe1be8de#diff-646ad6b10917e4385cbcc8c8524e24a2
export USER_NAME=developer
# Email must be "real" i.e. not email@mastodon.local
export USER_EMAIL=developer@example.com
export PRIVATE_DOMAIN_OR_IP=

export INSTANCE=mastodon-development
export NGINX_IP=172.32.0.10
export MSTDN_SUBNET=172.32.0.0/24
export MSTDN_IPV4_WEB=172.32.0.4
export MSTDN_IPV4_STREAMING=172.32.0.6
export MSTDN_IPV4_SIDEKIQ=172.32.0.8
# export SMTP_HOSTNAME=postfix
# export POSTFIX_IP=172.32.0.12

# cent os support, delete hyphens
export INSTANCE=${INSTANCE//-/}

cd $(dirname ${BASH_SOURCE})/../${INSTANCE}
#chown -hR ${USER} .

echo 'create app'
bash ${DIR}/create-mstdn.sh
echo 'create nginx'
bash ${DIR}/create-nginx.sh
# bash ${DIR}/create-postfix.sh

echo
echo
if [[ -n ${PRIVATE_DOMAIN_OR_IP} ]]; then
  echo "open ${PRIVATE_DOMAIN_OR_IP}:80 with :"
else
  echo "open ${NGINX_IP}:80 with :"
fi
cat ../account-${INSTANCE}-${USER_NAME}.md
# chown -hR ${USER} .

