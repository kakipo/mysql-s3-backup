#!/bin/bash
#
set -e

export PATH="$PATH:/usr/local/bin"

usage()
{
cat << EOF
usage: $0 parameters

This script dumps MySQL, tars it, then sends it to an Amazon S3 bucket.

PARAMETERS:
   -help   Show this message
   -u      MySQL user name
   -p      MySQL password
   -h      MySQL host <hostname><:port>
   -d      MySQL database
   -b      Amazon S3 bucket name
EOF
}

MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_HOST=
MYSQL_DB=
S3_BUCKET_NAME=

while getopts “u:p:h:d:b:” OPTION
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
    d)
      MYSQL_DB=$OPTARG
      ;;
    b)
      S3_BUCKET_NAME=$OPTARG
      ;;
    ?)
      usage
      exit
    ;;
  esac
done

if [[ -z $MYSQL_USER ]] || [[ -z $MYSQL_PASSWORD ]] || [[ -z $MYSQL_DB ]] || [[ -z $MYSQL_HOST ]] || [[ -z $S3_BUCKET_NAME ]]
then
  usage
  exit 1
fi

# Get the directory the script is being run from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUT_DIR=$DIR/restore
echo "output dir: $OUT_DIR"

LATEST_FILE_PATH=$(aws s3 ls -al s3://$S3_BUCKET_NAME --recursive | awk '{print $4}' | sort -r | head -1)
echo "latest backup file path: s3://$S3_BUCKET_NAME/$LATEST_FILE_PATH"

aws s3 cp s3://$S3_BUCKET_NAME/$LATEST_FILE_PATH $OUT_DIR/

TAR_FILE_NAME="$( ls -rt $OUT_DIR | tail -1 )"

# Untar Gzip the file
tar zxvf $OUT_DIR/$TAR_FILE_NAME -C $OUT_DIR

# Remove the tar file
rm $OUT_DIR/$TAR_FILE_NAME

# restore
LATEST_DUMP_FILE="$( ls -rt $OUT_DIR | tail -1 )"

echo "dumpfile: $OUT_DIR/$LATEST_DUMP_FILE"

mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$MYSQL_DB" < $LATEST_DUMP_FILE

# remove dump file
rm $OUT_DIR/$LATEST_DUMP_FILE
