FROM rclone/rclone

ENV MYSQLDUMP_OPTIONS ""
ENV MYSQLDUMP_DATABASE all
ENV MYSQL_HOST 127.0.0.1
ENV MYSQL_PORT 3306
ENV MYSQL_USER root
ENV MYSQL_PASSWORD root
ENV RCLONE_TARGET gdrive:/Backup

RUN apk --no-cache add mariadb-client gzip coreutils
ADD backup.sh /
RUN chmod +x /backup.sh

ENTRYPOINT [ "/backup.sh" ]
CMD ["sh", "/backup.sh"]