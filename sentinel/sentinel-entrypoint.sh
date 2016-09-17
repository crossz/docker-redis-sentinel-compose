#!/bin/sh

sed -i "s/\$SENTINEL_QUORUM/$SENTINEL_QUORUM/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_DOWN_AFTER/$SENTINEL_DOWN_AFTER/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_FAILOVER/$SENTINEL_FAILOVER/g" /etc/redis/sentinel.conf
sed -i "s/\$REQUIREPASS/$REQUIREPASS/g" /etc/redis/sentinel.conf

#redis-cli -h slave -a $REQUIREPASS config set masterauth $REQUIREPASS
#redis-cli -h redis-master -a $REQUIREPASS config set masterauth $REQUIREPASS

redis-cli -h slave -a $REQUIREPASS slaveof redis-master 6379

exec docker-entrypoint.sh redis-server /etc/redis/sentinel.conf --sentinel
