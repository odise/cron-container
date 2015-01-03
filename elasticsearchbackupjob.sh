#!/bin/bash

# TODO
# - AWS credentials as part of the request

ES_HOST=${ES_HOST_URL:-http://localhost:9200}
ES_REPO=${ES_REPOSITORY:-default_repo}
SNAPSHOTNAME=$(date "+%Y-%m-%d-%H-%M-%S")_${ES_SNAPSHOTNAME:-_}

AWS_KEY=${AWS_ACCESS_KEY_ID:-""}
AWS_SECRET=${AWS_SECRET_ACCESS_KEY:-""}
AWS_CREDENTIALS=""

if [ -n "$AWS_KEY" ] && [ -n "$AWS_SECRET" ]; then
  AWS_CREDENTIALS="\"secret_key\": \"$AWS_SECRET\", \"access_key\": \"$AWS_KEY\","
fi

echo "... Checking the repository ... "
code=$(curl -s -S -o /dev/stderr -w "%{http_code}" \
  "$ES_HOST/_snapshot/$ES_REPO?pretty")

# create it if it doesn't exists
if [ $code -ne 200 ]; then

  echo " ... Creating repository ..."
  code=$(curl -s -S -o /dev/stderr -w "%{http_code}" \
    -XPUT "$ES_HOST/_snapshot/$ES_REPO?pretty" -d "{
    \"type\": \"s3\",
    \"settings\": {
      \"bucket\": \"${AWS_S3_BUCKET}\",
      $AWS_CREDENTIALS
      \"region\": \"${AWS_REGION:-eu-west}\"
    }
  }")
  if [ $code -ne 200 ]; then
    echo " ... Couldn't create the backup repository $ES_REPO at $ES_HOST"
    return 1
  fi
fi

echo " ... Taking snapshot ..."
code=$(curl -s -S -o /dev/stderr -w "%{http_code}" \
  -XPUT "$ES_HOST/_snapshot/$ES_REPO/$SNAPSHOTNAME?wait_for_completion=true&pretty=true" -d '{
  "ignore_unavailable": "true",
  "include_global_state": false
}')
if [ $code -ne 200 ]; then
  echo " ... Couldn't create the snapshot on repository $ES_REPO at $ES_HOST"
  return 2
fi

echo " ... Checking snapshot ..."
code=$(curl -s -S -o /dev/stderr -w "%{http_code}" \
  -XGET "$ES_HOST/_snapshot/$ES_REPO/$SNAPSHOTNAME?pretty")

if [ $code -ne 200 ]; then
  echo " ... Couldn't check the snapshot on repository $ES_REPO at $ES_HOST"
  return 3
fi
