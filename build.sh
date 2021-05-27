#!/bin/sh -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
FROM="alpine:3.13"
VERSION=2.03
IMAGE=nextcloud_benchmark_v2
TO="christian773/$IMAGE"


cd $(dirname $0) 
curl https://raw.githubusercontent.com/joe-speedboat/shell.scripts/master/nc_benchmark.sh > nc_benchmark.sh
git tag -a v$VERSION -m "build tag $VERSION"
git commit -a -m "build tag $VERSION"
git push
git push --tags


docker system prune -a -f
sed -i "s@^FROM .*@FROM $FROM@" Dockerfile
sed -i "s@^ARG VERSION=.*@ARG VERSION=$VERSION@" Dockerfile

docker build -t $IMAGE:$VERSION .

for V in $VERSION latest
do
   docker tag $IMAGE:$VERSION $TO:$V
   docker push $TO:$V
done

