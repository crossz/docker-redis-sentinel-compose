MASERT_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredissentinelcompose_redismaster_1)
SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredissentinelcompose_redisslave_1)
#SENTINEL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredissentinelcompose_sentinel_1)
SENTINEL_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '172')

echo Redis master: $MASERT_IP
echo Redis Slave: $SLAVE_IP
echo ------------------------------------------------
echo Initial status of sentinel
echo ------------------------------------------------
docker-compose run --rm redismaster redis-cli -h $SENTINEL_IP -p 26479 info Sentinel

echo ------------------------------------------------
echo Pause redis master
docker pause dockerredissentinelcompose_redismaster_1
sleep 10
echo Current infomation of sentinel
docker-compose run --rm redismaster redis-cli -h $SENTINEL_IP -p 26479 info Sentinel

echo ------------------------------------------------
echo Unpause Redis master
docker unpause dockerredissentinelcompose_redismaster_1
sleep 5
echo Current infomation of sentinel
docker-compose run --rm redismaster redis-cli -h $SENTINEL_IP -p 26479 info Sentinel
