FROM progrium/busybox
RUN opkg-install curl bash

RUN curl -skL https://github.com/michaloo/go-cron/releases/download/v0.0.2/go-cron.tar.gz | \
   tar -x -C /root -f - 

RUN curl -skLo /root/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.4/ep-linux && chmod +x /root/ep

RUN curl -skLo /root/etcd-backup https://github.com/odise/etcd-backup/releases/download/v0.0.1/etcd-backup-linux && chmod +x /root/etcd-backup

# for some reason the linux release didn't worked for me
#RUN curl -skLo /root/gof3r https://github.com/rlmcpherson/s3gof3r/releases/download/v0.4.9/gof3r_0.4.9_linux_amd64.tar.gz && chmod +x /root/gof3r
ADD gof3r /root/gof3r
ADD https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt /etc/ssl/ca-bundle.pem

# add scheduler and create jobs entrypoint
ADD scheduler.sh /root/scheduler.sh
RUN chmod a+x /root/scheduler.sh
RUN mkdir /jobs

# thats our default
ADD etcdbackupjob.sh /jobs/job.sh
RUN chmod a+x /jobs/job.sh

# variable substitution and scheduler start
CMD [ "/root/ep", \
    "-v", "/jobs/*", \
    "-v", "/root/scheduler.sh", \
    "--", "/bin/sh", "/root/scheduler.sh" ]