# etcd-backup-cron

Run an ETCD backup task inside a Docker container and upload it to AWS S3.
The status of the last cron run can be checked on container port 18080. 
The resulting Docker container ahs a size of approx. 25mb.

# Environment variables to set

| Name | Description | Default |
|------|-------------|---------|
| GOCRON_SCHEDULE | Schedule string like "*/5 * * * * *" | None |
| CRONJOB_COMMAND | The command the scheduler will use. This is for further purposes. | "sh /jobs/job.sh" |
| AWS_ACCESS_KEY_ID | AWS_ACCESS_KEY for the upload of the dump. | None |
| AWS_SECRET_ACCESS_KEY | AWS_SECRET_ACCESS_KEY for the upload of the dump. | None |
| AWS_S3_BUCKET | AWS bucket for the uploaded file.| None |
| AWS_S3_ENDPOINT | AWS S3 endpoint | s3-eu-west-1.amazonaws.com |
| ETCD_DUMP_FILENAME | Name of the dump file (also on S3) | dump.json |
| ETCD_MACHINES | Urls to the ETCD cluster nodes. This is a list of strings. E.g. '"http://192.168.33.9:2379","http://192.168.33.10:2379"' | None |
| ETCD_LEADER | Url to the ETCD leader node. Eg.g "http://192.168.33.9:2379" | None |
| ETCD_KEY | ETCD directory node to dump. | /_coreos.com |

# Example usage

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
         -e ETCD_KEY=/_coreos.com \
				 -p 80:18080 \
         -P etcd-backup-cron
`

# Dependecies

* go-cron (https://github.com/odise/go-cron)
* etcd-backup (https://github.com/odise/etcd-backup)
* envplate (https://github.com/kreuzwerker/envplate)
* gof3r (https://github.com/rlmcpherson/s3gof3r)


