cat << EOF > /root/etcd-configuration.json
{
  "cluster": {
      "leader": "${ETCD_LEADER}",
      "machines": [
            ${ETCD_MACHINES:-""}
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
  "dumpFilePath": "/root/${ETCD_DUMP_FILENAME:-dump.json}",
  "backupStrategy": {
    "keys": ["${ETCD_KEY:-/_coreos.com}"],
    "sorted": false,
    "recursive": true
  }
}
EOF

/root/etcd-backup -config=/root/backup-configuration.json \
  -etcd-config=/root/etcd-configuration.json dump && \
  /root/gof3r cp --endpoint=${AWS_S3_ENDPOINT:-s3-eu-west-1.amazonaws.com} --debug /root/${ETCD_DUMP_FILENAME:-dump.json} s3://${AWS_S3_BUCKET}/${ETCD_DUMP_FILENAME:-dump.json}
