# Docker Image: nextcloud_benchmark_v2
This is a docker container made for reliable nextcloud performance and QA tests.   
It uses the shell script you can start on any linux machine without docker:   
* https://github.com/joe-speedboat/shell.scripts/blob/master/nc_benchmark.sh   
BENCH_COUNT defines the amount of iterations the test does.    
After each test, the script uploads its results to the nextcloud it is testing.   

## VARIABLES
### NC_FQDN
* mandatory
hostname of nextcloud: eg: cloud.mydomain.com:8443
### NC_USER
* mandatory
* default: admin
nextcloud webdav user
### NC_PASS
* mandatory
Password or Token (Nextcloud > Settings > Security)

### BENCH_COUNT
* optional
* default: 0 (forever)
number of test runs before exiting container

### TEST_BLOCK_SIZE_MB
* optional
* default: random value picked from range 10-2048
* you can pass range as value and each test will pick a random val from this range
eg: 1-10 with BENCH_COUNT=5 may result in 5 different values between 1 and 10

### TEST_FILES_COUNT
* optional
* default: random value picked from range 10-200
* you can pass range as value and each test will pick a random val from this range
eg: 1-10 with BENCH_COUNT=5 may result in 5 different values between 1 and 10

### SPEED_LIMIT_UP_MBIT
* optional, Megabit/second
* default: random value picked from range 10-100
* you can pass range as value and each test will pick a random val from this range
eg: 1-10 with BENCH_COUNT=5 may result in 5 different values between 1 and 10

### SPEED_LIMIT_DOWN_MBIT
* optional, Megabit/second
* default: random value picked from range 10-100
* you can pass range as value and each test will pick a random val from this range
eg: 1-10 with BENCH_COUNT=5 may result in 5 different values between 1 and 10


## Docker detached start example
```
docker run -d --rm -t --name bench -e NC_FQDN=cloud.domain.com -e NC_USER=tom -e NC_PASS=NQrgs-....-HLGAE -e TEST_FILES_COUNT=1-30 -e TEST_BLOCK_SIZE_MB=1-10 -e BENCH_COUNT=3 -e SPEED_LIMIT_UP_MBIT=500 -e SPEED_LIMIT_DOWN_MBIT=500 christian773/nextcloud_benchmark_v2:latest
```

## Docker detached load test example
```
# fire the load
for c in {1..20}
do
   docker run -d --rm -t --name bench$c -e NC_FQDN=cloud.domain.com -e NC_USER=tom -e NC_PASS=NQrgs-....-HLGAE -e TEST_FILES_COUNT=1-30 -e TEST_BLOCK_SIZE_MB=1-10 -e BENCH_COUNT=3 -e SPEED_LIMIT_UP_MBIT=500 -e SPEED_LIMIT_DOWN_MBIT=500 christian773/nextcloud_benchmark_v2:latest
done
docker ps
docker logs -f bench1

# shut it down
for c in {1..20}
do
   docker kill bench$c
done
docker ps
```


