#!/bin/sh

MYSQL_OPTS="-h $MYSQL_HOST -P $MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD --skip-ssl"
DUMP_START_TIME=$(date +"%Y-%m-%dT%H%M%SZ")
TMP_FOLDER="/tmp/$DUMP_START_TIME"
GDRIVE_FOLDER="$RCLONE_TARGET/$DUMP_START_TIME"

if [ "${MYSQLDUMP_DATABASE}" = "all" ]; then
  DATABASES=`mariadb $MYSQL_OPTS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys|innodb)"`
else
  DATABASES=$(echo $MYSQLDUMP_DATABASE | tr ";" "\n")
fi

mkdir -p "$TMP_FOLDER"

for DB in $DATABASES; do
  echo "Creating dump of ${DB} from ${MYSQL_HOST}..."

  DUMP_FILE="${TMP_FOLDER}/${DB}.sql.gz"

  mariadb-dump $MYSQL_OPTS $MYSQLDUMP_OPTIONS $DB | gzip > $DUMP_FILE
done

rclone mkdir "$GDRIVE_FOLDER"
rclone copy "${TMP_FOLDER}/" "${GDRIVE_FOLDER}/"
