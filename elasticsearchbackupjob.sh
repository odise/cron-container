#!/bin/bash

echo "Checking the repository ... "
code=$(curl -s -o /dev/null -w "%{http_code}" \
  '${ES_HOST_URL}/_snapshot/${ES_REPOSITORY}')

# create it if it doesn't exists
if [ $code -ne 200 ]; then

  echo " ... Creating repository ..."
  code=$(curl -s -o /dev/null -w "%{http_code}" \
    -XPUT '${ES_HOST_URL}/_snapshot/${ES_REPOSITORY}' -d '{
    "type": "s3",
    "settings": {
      "bucket": "${AWS_S3_BUCKET}",
      "region": "${AWS_REGION:-eu-west}"
    }
  }')
  if [ $code -ne 200 ]; then
    echo " ... Couldn't create the backup repository ${ES_REPOSITORY} at ${ES_HOST_URL}"
    return 1
  fi
fi

SNAPSHOTNAME=$(date "+%Y-%m-%d-%H-%M-%S")_${ES_SNAPSHOTNAME:-_}

echo " ... Taking snapshot ..."
curl -s -S \
  -XPUT "${ES_HOST_URL}/_snapshot/${ES_REPOSITORY}/$SNAPSHOTNAME?wait_for_completion=true" -d '{
  "ignore_unavailable": "true",
  "include_global_state": false
}'

echo " ... Checking snapshot ..."
curl -s -S "${ES_HOST_URL}/_snapshot/${ES_REPOSITORY}/$SNAPSHOTNAME?pretty"
