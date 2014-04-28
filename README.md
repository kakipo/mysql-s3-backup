mysql-s3-backup
===============

backup MySQL to S3

Requirements
---------------

* mysqldump
* (configured) aws-cli  
https://aws.amazon.com/cli/
* tar

## Usage

`bash /path/to/backup.sh -u MYSQL_USER -p MYSQL_PASSWORD -o MYSQL_HOST -b S3_BUCKET`

## Cron

### Daily

Add the following line to `/etc/cron.d/db-backup` to run the script every day at midnight (UTC time)

    0 0 * * * root /bin/bash /path/to/backup.sh -u MYSQL_USER -p MYSQL_PASSWORD -o MYSQL_HOST -b S3_BUCKET`
