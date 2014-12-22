# etcd-backup-cron

Run an ETCD backup or Elasticsearch index backup task inside a Docker container and upload it to AWS S3.
The status of the last cron run can be checked on container port 18080. 
The resulting Docker container ahs a size of approx. 25mb.

# Environment variables to set

As `envplate` will parse all files in the repo it is necessary to define alle environment variables which 
do not have a default value set even if it is for an other job.

| Name | Description | Default | used by job |
|------|-------------|---------|-------------|
| GOCRON_SCHEDULE | Schedule string like "*/5 * * * * *" | None | global |
| CRONJOB_COMMAND | The command the scheduler will use. The current implementation supports two options: `etcbackupjob.sh` and `elasticsearchbackupjob.sh`. | "etcbackupjob.sh" | global |
| AWS_ACCESS_KEY_ID | AWS_ACCESS_KEY for the upload of the dump. | None | etcdbackupjob.sh |
| AWS_SECRET_ACCESS_KEY | AWS_SECRET_ACCESS_KEY for the upload of the dump. | None | etcdbackupjob.sh |
| AWS_S3_BUCKET | AWS bucket for the uploaded file.| None | etcdbackupjob.sh, elasticsearchbackupjob.sh |
| AWS_S3_ENDPOINT | AWS S3 endpoint | s3-eu-west-1.amazonaws.com | etcdbackupjob.sh, elasticsearchbackupjob.sh |
| AWS_S3_REGION | AWS S3 region | eu-west | elasticsearchbackupjob.sh |
| ETCD_DUMP_FILENAME | Name of the dump file (also on S3) | dump.json | etcdbackupjob.sh |
| ETCD_MACHINES | Urls to the ETCD cluster nodes. This is a list of strings. E.g. '"http://192.168.33.9:2379","http://192.168.33.10:2379"' | "http://localhost:2379" | etcdbackupjob.sh |
| ETCD_LEADER | Url to the ETCD leader node. E.g. "http://192.168.33.9:2379" | http://localhost:2379 | etcdbackupjob.sh |
| ETCD_KEY | ETCD directory node to dump. | /_coreos.com | etcdbackupjob.sh |
| ES_SNAPSHOTNAME | Customizable part of the ES snapshot name. Pattern that will be used $(date "+%Y-%m-%d-%H-%M-%S")_${ES_SNAPSHOTNAME}. | _ | elasticsearchbackupjob.sh |
| ES_HOST_URL | Url to the ES node the backup will be triggered e.g. http://192.168.33.9:9200 | http://localhost:9200 | elasticsearchbackupjob.sh |
| ES_REPOSITORY | Snapshot repository name. | default_repo | elasticsearchbackupjob.sh |

# Example usage

For ETCD backups:

`
docker run -d --name etcdbackup \
         -e GOCRON_SCHEDULE="0 1 * * * *" \
         -e CRONJOB_COMMAND="etcdbackupjob.sh" \
         -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY \
         -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
         -e AWS_S3_BUCKET=de.kreuzwerker.jan.test \
         -e AWS_S3_ENDPOINT=s3-eu-west-1.amazonaws.com \
         -e ETCD_DUMP_FILENAME="etcd_cluster_dump.json" \
         -e ETCD_LEADER="http://192.168.33.9:2379" \
         -e ETCD_MACHINES='"http://192.168.33.9:2379","http://192.168.33.10:2379","http://192.168.33.11:2379"' \
         -e ETCD_KEY=/_coreos.com \
         -p 80:18080 \
         -P etcd-backup-cron
`

And an example for ES backups. Note that AWS credentials can be set in the ES cluster configuration as well. See configuration
options for the AWS plugin of ES here: https://github.com/elasticsearch/elasticsearch-cloud-aws#s3-repository

`
docker run -d --name elasticsearchbackup \
         -e GOCRON_SCHEDULE="0 0/3 * * * *" \
         -e CRONJOB_COMMAND="elasticsearchbackupjob.sh" \
         -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY \
         -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
         -e AWS_S3_BUCKET=de.kreuzwerker.jan.test \
         -e AWS_S3_ENDPOINT=s3-eu-west-1.amazonaws.com \
         -e ES_REPOSITORY=es_backup_s3_repo \
         -e ES_HOST_URL="http://192.168.33.9:9200" \
         -e ES_SNAPSHOTNAME=my_fancy_production_snapshot \
         -p 80:18080 \
         -P etcd-backup-cron
`

# Dependecies

* go-cron (https://github.com/odise/go-cron)
* etcd-backup (https://github.com/odise/etcd-backup)
* envplate (https://github.com/kreuzwerker/envplate)
* gof3r (https://github.com/rlmcpherson/s3gof3r)


