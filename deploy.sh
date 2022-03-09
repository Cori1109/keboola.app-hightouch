#!/bin/sh
set -e

env

# compatibility with travis and bitbucket
if [ ! -z ${BITBUCKET_TAG} ]
then
	echo "assigning bitbucket tag"
	export TAG="$BITBUCKET_TAG"
elif [ ! -z ${TRAVIS_TAG} ]
then
	echo "assigning travis tag"
	export TAG="$TRAVIS_TAG"
elif [ ! -z ${GITHUB_TAG} ]
then
	echo "assigning github tag"
	export TAG="$GITHUB_TAG"
else
	echo No Tag is set!
	exit 1
fi

echo "Tag is '${TAG}'"

#check if deployment is triggered only in master
if [ ${BITBUCKET_BRANCH} != "master" ]; then
               echo Deploy on tagged commit can be only executed in master!
               exit 1
fi

# Obtain the component repository and log in
echo "Obtain the component repository and log in"
docker pull quay.io/keboola/developer-portal-cli-v2:latest
export REPOSITORY=`docker run --rm  \
    -e KBC_DEVELOPERPORTAL_USERNAME \
    -e KBC_DEVELOPERPORTAL_PASSWORD \
    quay.io/keboola/developer-portal-cli-v2:latest \
    ecr:get-repository ${KBC_DEVELOPERPORTAL_VENDOR} ${KBC_DEVELOPERPORTAL_APP}`

echo "Set credentials"
eval $(docker run --rm \
    -e KBC_DEVELOPERPORTAL_USERNAME \
    -e KBC_DEVELOPERPORTAL_PASSWORD \
    quay.io/keboola/developer-portal-cli-v2:latest \
    ecr:get-login ${KBC_DEVELOPERPORTAL_VENDOR} ${KBC_DEVELOPERPORTAL_APP})

# Push to the repository
echo "Push to the repository"
docker tag ${APP_IMAGE}:latest ${REPOSITORY}:${TAG}
docker tag ${APP_IMAGE}:latest ${REPOSITORY}:latest
docker push ${REPOSITORY}:${TAG}
docker push ${REPOSITORY}:latest

# Update the tag in Keboola Developer Portal -> Deploy to KBC
if echo ${TAG} | grep -c '^v\?[0-9]\+\.[0-9]\+\.[0-9]\+$'
then
    docker run --rm \
        -e KBC_DEVELOPERPORTAL_USERNAME \
        -e KBC_DEVELOPERPORTAL_PASSWORD \
        quay.io/keboola/developer-portal-cli-v2:latest \
        update-app-repository ${KBC_DEVELOPERPORTAL_VENDOR} ${KBC_DEVELOPERPORTAL_APP} ${TAG} ecr ${REPOSITORY}
else
    echo "Skipping deployment to KBC, tag ${TAG} is not allowed."
fi
