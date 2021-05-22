# docker.nextcloud_benchmark
Nextcloud Webdav Benchmark loop

## VARIABLES
```
# mandatory hostname of nextcloud: eg: cloud.mydomain.com:8443
CLOUD="cloud.comain.com"
# mandatory nextcloud user, default is admin
USR="..."
# mandatory password or token
PW="..."
# optional in in Megabytes: default is random 10-4096
TEST_BLOCK_SIZE_MB="50"
# optional: default is random 10-200
TEST_FILES_COUNT="10"
# optional in Megabytes/s: default is random 1M-200M
SPEED_LIMIT_UP="10M"
# optional in Megabytes/s: default is random 1M-200M
SPEED_LIMIT_DOWN="10M"
# optional: amount of tests to run before stopping the container: default is 9999999
BENCH_COUNT=10
```

## Docker attached start example
```
# docker run -e CLOUD=nc.domain.ch -e USR=admin -e PW='super_secret' -e TEST_FILES_COUNT=10 -e SPEED_LIMIT_UP=10M -e SPEED_LIMIT_DOWN=10M -e TEST_BLOCK_SIZE_MB=50 christian773/nextcloud_benchmark:latest
####################### STARTING ########################

CLOUD="..."
USR="..."
PW="..."
TEST_BLOCK_SIZE_MB="50"
TEST_FILES_COUNT="10"
BENCH_DIR="9207ceec21a4"
SPEED_LIMIT_UP="10M"
SPEED_LIMIT_DOWN="10M"
LOCAL_DIR=/tmp

#########################################################
INFO: Testing connectivity
INFO: reading external config file: nc_benchmark.sh.conf
INFO: create /tmp/50.mb with random data
INFO: generating md5sum of /tmp/50.mb
upload 50 MB starting: 2021.05.20 22:20:41
upload 50 MB finished: 2021.05.20 22:20:47
wait for 50.mb to get assembled on nextcloud
50.mb
download 50 MB starting: 2021.05.20 22:20:48
download 50 MB finished: 2021.05.20 22:20:56
------ DETAILS BEFORE UPLOAD BIG FILE ------
29e97efbac8b67c12bfbfa0a65ac19e3  /tmp/50.mb
-rw-r--r-- 1 1997 root 52428800 May 20 22:20 /tmp/50.mb
------ DETAILS AFTER DOWNLOAD BIG FILE ------
29e97efbac8b67c12bfbfa0a65ac19e3  /tmp/50.mb.download
-rw-r--r-- 1 1997 root 52428800 May 20 22:20 /tmp/50.mb.download
upload file 10.txt
download file 10.txt
BURL=https://share.bitbull.ch
TEST_BLOCK_SIZE_MB=50
UL_BLOCK_SPEED=8336 KByte/s
UL_BLOCK_ASSEMBLING_SEC=1 sec
DL_BLOCK_SPEED=6494 KByte/s
TEST_FILES_COUNT=10
DL_ERROR_CNT=0
UL_ERROR_CNT=0
UL_FILES_TIME=10 sec
DL_FILES_TIME=9 sec
SPEED_LIMIT_DOWN=10M
SPEED_LIMIT_UP=10M
uploading results: /tmp/9207ceec21a4.txt to https://share.bitbull.ch/remote.php/dav/files/admin/
cleaning up test files
   delete directory: 9207ceec21a4/small_files
   delete file: 9207ceec21a4/50.mb
   delete trash object: 50.mb.d1621549277
   delete trash object: small_files.d1621549276/
done
SLEEPING 10 seconds
... now it starts looping ... :-)
```

## Docker detached start example
```
docker run -d --rm -t --name bench -e CLOUD=nc.domain.ch -e USR=admin -e PW='super_secret' christian773/nextcloud_benchmark:latest
```

## Docker detached load test example
```
# fire the load
for c in {1..20}
do
   docker run -d --rm -t --name bench$c -e CLOUD=nc.domain.ch -e USR=admin -e PW='super_secret' -e TEST_FILES_COUNT=20 -e SPEED_LIMIT_UP=1M -e SPEED_LIMIT_DOWN=1M -e TEST_BLOCK_SIZE_MB=5 christian773/nextcloud_benchmark:latest
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


