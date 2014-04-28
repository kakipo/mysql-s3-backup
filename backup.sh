#!/bin/bash
#

set -e

export PATH="$PATH:/usr/local/bin"

usage()
{
cat << EOF
usage: $0 options

This script dumps MySQL, tars it, then sends it to an Amazon S3 bucket.

OPTIONS:
   -help   Show this message
   -u      MySQL user name
   -p      MySQL password
   -h      MySQL host <hostname><:port>
   -b      Amazon S3 bucket name
EOF
}

MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_HOST=
S3_BUCKET=

while getopts “u:p:h:b:” OPTION
do
  case $OPTION in
    u)
      MYSQL_USER=$OPTARG
      ;;
    p)
      MYSQL_PASSWORD=$OPTARG
      ;;
    h)
      MYSQL_HOST=$OPTARG
      ;;
    b)
      S3_BUCKET=$OPTARG
      ;;
    ?)
      usage
      exit
    ;;
  esac
done

if [[ -z $MYSQL_USER ]] || [[ -z $MYSQL_PASSWORD ]] || [[ -z $S3_BUCKET ]]
then
  usage
  exit 1
fi
if [[ -z $MYSQL_HOST ]]
then
  MYSQL_HOST="localhost:3306"
fi

# Get the directory the script is being run from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR

# Store the current date in the format: YYYY-mm-DD-HHMMSS
DATE=$(date -u "+%F-%H%M%S")
FILE_NAME="backup-$DATE"
ARCHIVE_NAME="$FILE_NAME.tar.gz"

# dump & tar
mysqldump -u "MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" > $/DIR/backup/$FILE_NAME
tar -C $DIR/backup/ -zcvf $DIR/backup/$ARCHIVE_NAME $FILE_NAME/

# Remove the backup file
rm -r $DIR/backup/$FILE_NAME

# Send the dump to S3
DATE_YYYY=$(date -u "+%Y")
DATE_YYYYMM=$(date -u "+%Y-%m")

aws s3 mv $DIR/backup/$ARCHIVE_NAME s3://$S3_BUCKET/$DATE_YYYY/$DATE_YYYYMM/$ARCHIVE_NAME
