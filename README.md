# wenchenx/mariadb-backup-gdrive

# Introduction

This will build a container for backing up MariaDB and upload to Cloud Service(ex: Google Drive) using rclone. 

# Build Image
`docker build -t wenchenx/mariadb-backup-gdrive:latest .`

# Environment Variable
- `MYSQLDUMP_OPTIONS` mysqldump options (default: "")
- `MYSQLDUMP_DATABASE` list of databases you want to backup seperated by ; (default: all)
- `MYSQL_HOST` the mysql host (default: 127.0.0.1)
- `MYSQL_PORT` the mysql port (default: 3306)
- `MYSQL_USER` the mysql user (default: root)
- `MYSQL_PASSWORD` the mysql password (default: root)
- `RCLONE_TARGET` the rclone target (default: gdrive:/Backup)

# Rclone config
1. [create rclone config](https://rclone.org/commands/rclone_config_create/), and it will generate `~/.config/rclone/rclone.conf`
2. `mkdir rclone; cp ~/.config/rclone/rclone.conf ./rclone/`
3. Mount `./rclone/` to `/config/rclone`

# Docker Example
```
docker run \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=root \
  -e MYSQL_HOST=host.docker.internal \
  -e RCLONE_TARGET=gdrive:/Backup/Test \
  -v $(pwd)/rclone:/config/rclone/ \
  --add-host=host.docker.internal:host-gateway \
  wenchenx/mariadb-backup-gdrive
```

# K8s Cronjob Example
1. Generate ConfigMap
```
kubectl create configmap rclone --from-file=rclone/rclone.conf
```
2. Deploy Cronjob
```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: mariadb-backup-cronjob
spec:
  schedule: "0 20 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - image: wenchenx/mariadb-backup-gdrive:latest
              name: rclone-cronjob
              env:
                - name: MYSQL_HOST
                  value: 127.0.0.1
                - name: MYSQL_USER
                  value: root
                - name: MYSQL_PASSWORD
                  value: root
                - name: RCLONE_TARGET
                  value: gdrive:/Backup/Test
              volumeMounts:
                - name: rclone
                  mountPath: /config/rclone/rclone.conf
                  subPath: rclone.conf
          volumes:
            - name: rclone
              configMap:
                name: rclone
```
