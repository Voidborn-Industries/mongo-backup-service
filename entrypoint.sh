#!/bin/sh
# This script runs when the container starts. Its job is to set up the cron schedule.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the required environment variables are set. If not, print an error and exit.
if [ -z "${SOURCE_MONGO_URI}" ] || [ -z "${DESTINATION_MONGO_URI}" ] || [ -z "${BACKUP_SCHEDULE}" ]; then
  echo "ERROR: The SOURCE_MONGO_URI, DESTINATION_MONGO_URI, and BACKUP_SCHEDULE environment variables must be set."
  exit 1
fi

# Create a crontab file using the schedule from the environment variable.
# The '>> /var/log/cron.log 2>&1' part redirects the script's output to a log file
# inside the container, which you can view with 'docker logs'.
echo "${BACKUP_SCHEDULE} /app/backup.sh >> /var/log/cron.log 2>&1" > /etc/crontab

# Add a required newline to the end of the crontab file.
echo "" >> /etc/crontab

echo "Cron schedule configured: ${BACKUP_SCHEDULE}"
echo "Container entrypoint initialized. Starting cron..."
echo "----------------------------------------------------"

# Execute the command passed to this script (which is `cron -f` from the Dockerfile)
# This starts the cron daemon in the foreground, keeping the container running.
exec "$@"
