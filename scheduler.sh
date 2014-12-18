/root/go-cron "${GOCRON_SCHEDULE}" sh /jobs/${CRONJOB_COMMAND:-etcdbackupjob.sh}
