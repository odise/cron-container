DUMPFILE=${ETCD_DUMP_FILENAME:-dump.json}

cat << EOF > /root/etcd-configuration.json
{
  "cluster": {
      "leader": "${ETCD_LEADER:-http://localhost:2379}",
      "machines": [
            ${ETCD_MACHINES:-"http://localhost:2379"}
          ]
    },
  "config": {
      "certFile": "",
      "keyFile": "",
      "caCertFiles": [],
      "timeout": 10000000000000,
      "consistency": "STRONG"
    }
}
EOF

cat << EOF > /root/backup-configuration.json
{
  "concurrentRequests": 50,
  "retries": 5,
  "dumpFilePath": "/root/$DUMPFILE",
  "backupStrategy": {
    "keys": ["${ETCD_KEY:-/_coreos.com}"],
    "sorted": false,
    "recursive": true
  }
}
EOF

/root/etcd-backup -config=/root/backup-configuration.json \
  -etcd-config=/root/etcd-configuration.json dump && \
  /root/gof3r cp --endpoint=${AWS_S3_ENDPOINT:-s3-eu-west-1.amazonaws.com} \
  --debug /root/$DUMPFILE s3://${AWS_S3_BUCKET}/$DUMPFILE
