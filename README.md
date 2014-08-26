mysql-s3-backup
===============

Backup from MySQL to S3 & Restore from S3 to MySQL

Requirements
---------------

* mysqldump
* (configured) aws-cli  
https://aws.amazon.com/cli/
* tar

## Usage

### Backup

`bash /path/to/backup.sh -u FROM_MYSQL_USER -p FROM_MYSQL_PASSWORD -h FROM_MYSQL_HOST -d FROM_MYSQL_DATABASE -b TO_S3_BUCKET_NAME`

### Restore

`bash /path/to/restore.sh -u TO_MYSQL_USER -p TO_MYSQL_PASSWORD -h TO_MYSQL_HOST -d TO_MYSQL_DATABASE -b FROM_S3_BUCKET_NAME`

## Cron

### Daily

Add the following line to `/etc/cron.d/db-backup` to run the script every day at midnight (UTC time)


```
0 0 * * * root /bin/bash /path/to/backup.sh -u FROM_MYSQL_USER -p FROM_MYSQL_PASSWORD -h FROM_MYSQL_HOST -d FROM_MYSQL_DATABASE -b TO_S3_BUCKET_NAME
```
