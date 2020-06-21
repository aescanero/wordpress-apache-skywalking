#!/usr/bin/env sh

sky-php-agent --grpc ${SW_AGENT_COLLECTOR_BACKEND_SERVICES} --socket /tmp/sky-agent.sock > /var/log/sky-php.log 2>&1 &

docker-entrypoint.sh $@

