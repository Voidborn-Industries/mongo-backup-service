#!/bin/sh
# This is the core script that performs the backup and restore operation.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "=> Backup started at $(date +'%Y-%m-%d %H:%M:%S')"

# Use mongodump to get data from the source URI and pipe it directly to mongorestore.
# --archive: Allows streaming data without saving a temporary file to disk.
# --gzip: Compresses the data stream for faster and more efficient network transfer.
mongodump --uri="${SOURCE_MONGO_URI}" --archive --gzip \
| mongorestore \
    --uri="${DESTINATION_MONGO_URI}" \
    --archive \
    --gzip \
    --drop # This option deletes collections from the local DB before restoring, ensuring an exact mirror.

echo "=> Backup successfully completed at $(date +'%Y-%m-%d %H:%M:%S')"
echo "----------------------------------------------------"
