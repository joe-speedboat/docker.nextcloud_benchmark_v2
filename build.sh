#!/bin/sh -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
FROM="alpine:3.13"
VERSION=0.01
IMAGE=nc_bench2
TO="christian773/$IMAGE"


cd $(dirname $0) 
git tag -a v$VERSION -m "build tag $VERSION"
docker system prune -a -f
git commit -a -m "build tag $VERSION"
git push
git push --tags

sed -i "s@^FROM .*@FROM $FROM@" Dockerfile
sed -i "s@^ARG VERSION=.*@ARG VERSION=$VERSION@" Dockerfile

docker build -t $IMAGE:$VERSION .

for V in $VERSION latest
do
   docker tag $IMAGE:$VERSION $TO:$V
   docker push $TO:$V
done

