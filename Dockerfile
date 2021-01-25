FROM alpine

ENV SSH_USER=sftpuser
ENV SSH_PASS=sftppass
ENV ROOT_PASS=rootpass

RUN apk add --no-cache bash openssh rsyslog shadow
RUN mkdir -m2755 /data
RUN groupadd sftp_users
RUN groupadd staff
RUN GROUPID=$(getent group sftp_users | cut -d: -f3) && useradd -d /data/$SSH_USER -g sftp_users -M -N -o -s /bin/false -u $GROUPID $SSH_USER
RUN useradd -d /data/oliver -g staff -M -N oliver
RUN echo "$SSH_USER:$SSH_PASS" | chpasswd
RUN echo "oliver:olipass" | chpasswd
RUN echo -e "$ROOT_PASS\n$ROOT_PASS" | passwd
RUN mkdir -m2755 /data/$SSH_USER
RUN mkdir -m2755 /data/$SSH_USER/dev
RUN mkdir /data/$SSH_USER/upload
RUN chown -R $SSH_USER:sftp_users /data/$SSH_USER/upload
RUN mkdir -m2755 /data/oliver
RUN mkdir -m2755 /data/oliver/dev
RUN mkdir /data/oliver/upload
RUN ssh-keygen -A
RUN mv /etc/sshd_config /etc/ssh/sshd_config.old
ADD sshd_config /etc/ssh/sshd_config
#COPY sshd_config /etc/ssh/sshd_config

RUN mkdir /etc/rsyslog.d
ADD sftp.conf /etc/rsyslog.d/sftp.conf

EXPOSE 22
ADD sftp.sh sftp.sh
RUN chmod 755 sftp.sh
CMD ./sftp.sh
