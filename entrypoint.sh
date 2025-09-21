#!/bin/sh
# This script runs when the container starts. Its job is to set up the cron schedule.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the required environment variables are set. If not, print an error and exit.
if [ -z "${SOURCE_MONGO_URI}" ] || [ -z "${DESTINATION_MONGO_URI}" ] || [ -z "${BACKUP_SCHEDULE}" ]; then
  echo "ERROR: The SOURCE_MONGO_URI, DESTINATION_MONGO_URI, and BACKUP_SCHEDULE environment variables must be set."
  exit 1
fi

# Create environment file for cron to use
echo "SOURCE_MONGO_URI=${SOURCE_MONGO_URI}" > /app/backup.env
echo "DESTINATION_MONGO_URI=${DESTINATION_MONGO_URI}" >> /app/backup.env
echo "BACKUP_SCHEDULE=${BACKUP_SCHEDULE}" >> /app/backup.env

# Create a wrapper script that sources the environment
cat > /app/backup_wrapper.sh << 'EOF'
#!/bin/sh
# Load environment variables
. /app/backup.env
# Run the backup script
/app/backup.sh >> /var/log/cron.log 2>&1
EOF

# Make the wrapper script executable
chmod +x /app/backup_wrapper.sh

# Create a crontab file using the schedule from the environment variable.
# Note: /etc/crontab format requires: minute hour day month weekday user command
echo "${BACKUP_SCHEDULE} root /app/backup_wrapper.sh" > /etc/crontab

# Add a required newline to the end of the crontab file.
echo "" >> /etc/crontab

# Create log directory and file
mkdir -p /var/log
touch /var/log/cron.log

# Display the crontab for debugging
echo "Cron schedule configured: ${BACKUP_SCHEDULE}"
echo "Crontab contents:"
cat /etc/crontab
echo ""
echo "Environment file contents:"
cat /app/backup.env
echo ""
echo "Logs will be written to /var/log/cron.log"
echo "----------------------------------------------------"

# Start cron and show initial logs
echo "Starting cron daemon..."

# Execute the command passed to this script (which is `cron -f` from the Dockerfile)
# This starts the cron daemon in the foreground, keeping the container running.
exec "$@"
