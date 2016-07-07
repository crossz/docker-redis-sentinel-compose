# redis-cluster 
**Redis cluster with Docker Compose** 

Using Docker Compose to setup a redis cluster for testing sentinel failover.

This project is inspired by the project of [https://github.com/mdevilliers/docker-rediscluster][1]


## Prerequisite

Install [Docker][4] and [Docker Compose][3] in testing environment

Optional: 
Install the redis-cli. E.g. with following command in Ubuntu 

```
apt-get install redis-server
```

## Docker Compose template of Redis cluster

The tempalte defines the topology of the Redis cluster

```
redismaster:
  image: redis:3.2
redisslave:
  image: redis:3.2
  links:
    - redismaster
sentinel:
  build: sentinel
  ports:
    - "26479:26379"
  links:
    - redismaster
    - redisslave
    - redisconfig
redisconfig:
  build: redis-config
  links:
    - redismaster
    - redisslave
```

There are following nodes in the cluster,

* redismaster: Redis master
* redisslave:  Redis slave
* sentinel:    Sentinel instance
* redisconfig: Redis CLI to config the master/slave which will exit after configuraion


The sentinels are configured with a "mymaster" instance with the following properties -

```
sentinel monitor mymaster redismaster 6379 2
sentinel down-after-milliseconds mymaster 1000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 1000
```

The details could be found in sentinel/sentinel.conf



## Play with it


Start the redis cluster

```
docker-compose up
```

Check the status of redis cluster

```
docker-compose ps
```

The result is 

```
Name                         Command                          State    Ports   
dockerredissentinelcompose_redisconfig_1   /entrypoint.sh /bin/sh -c  ...   Exit 0             
dockerredissentinelcompose_redismaster_1   /entrypoint.sh redis-server      Up       6379/tcp  
dockerredissentinelcompose_redisslave_1    /entrypoint.sh redis-server      Up       6379/tcp  
dockerredissentinelcompose_sentinel_1      redis-sentinel /etc/redis/ ...   Up       26479/tcp
```

Scale out the instance number of sentinel


```
~~ docker-compose scale sentinel=3 ~~
```

Check the status of redis cluster:

Due to port forwarding assign in the docker-compose.yml, it could not scale.

```
docker-compose ps
```

The result is 

```
Name                         Command                          State    Ports   
dockerredissentinelcompose_redisconfig_1   /entrypoint.sh /bin/sh -c  ...   Exit 0             
dockerredissentinelcompose_redismaster_1   /entrypoint.sh redis-server      Up       6379/tcp  
dockerredissentinelcompose_redisslave_1    /entrypoint.sh redis-server      Up       6379/tcp  
dockerredissentinelcompose_sentinel_1      redis-sentinel /etc/redis/ ...   Up       26379/tcp 
~~ rediscluster_sentinel_2      redis-sentinel /etc/redis/ ...   Up       26379/tcp ~~
~~ rediscluster_sentinel_3      redis-sentinel /etc/redis/ ...   Up       26379/tcp ~~
```



Execut the test scripts
```
./test.sh
```
This script simulate pause/unpause the Redis master. Especially for the quorum. (here more tests need to be done manulaly)

The configuration:

a) with quorum of 2 (3 sentinels) makes the test.sh go through redis master automatically switch.

b) with quorum of 2 (1 sentinels): no switch, but with status=down only; even stop can not make it switch.

c) with quorum of 1 (whatever X sentinels): automatically switch.

Also manual simulation about  stop and recover the Redis master. And you will see the master is switched to slave automatically. 


```
docker pause rediscluster_redismaster_1
docker unpause rediscluster_redismaster_1
```
And get the sentinel infomation with following commands

```
SENTINEL_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '172')
redis-cli -h $SENTINEL_IP -p 26479 info Sentinel
```

Check the master and slave info about replication:

```
MASERT_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredissentinelcompse_redismaster_1)
SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredissentinelcompse_redisslave_1)

redis-cli -h $MASERT_IP -p 6379 info replication
redis-cli -h $SLAVE_IP -p 6379 info replication

```



Remove all redis related containers:

```
docker rm -f `docker ps -qa -f name=redis`
```

## References

[https://github.com/mdevilliers/docker-rediscluster][1]

[https://registry.hub.docker.com/u/joshula/redis-sentinel/] [2]

[1]: https://github.com/mdevilliers/docker-rediscluster
[2]: https://registry.hub.docker.com/u/joshula/redis-sentinel/
[3]: https://docs.docker.com/compose/
[4]: https://www.docker.com


## Contributors

* Li Yi (<denverdino@gmail.com>)
* Ty Alexander (<ty.alexander@gmail.com>)
