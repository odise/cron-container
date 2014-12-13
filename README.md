Run an ETCD backup task inside a Docker container and upload it to AWS S3. This will create a container of
approx. 25mb size.

`
docker run -d \
         -e GOCRON_SCHEDULE="*/5 * * * * *" \
         -e CRONJOB_COMMAND="sh /jobs/job.sh" \
         -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY \
         -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
         -e AWS_S3_BUCKET=de.kreuzwerker.jan.test \
         -e AWS_S3_ENDPOINT=s3-eu-west-1.amazonaws.com \
         -e ETCD_MACHINES='"http://192.168.33.9:2379"' \
         -e ETCD_LEADER="http://192.168.33.9:2379" \
         -e ETCD_KEY=-/_coreos.com \
         -P etcd-backup-cron
`
