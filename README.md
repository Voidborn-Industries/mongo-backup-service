# MongoDB Backup Service

A containerized service that automatically backs up MongoDB databases using `mongodump` and `mongorestore`. The service streams data directly between source and destination databases.

## Running the service

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SOURCE_MONGO_URI` | Yes | Connection string for the source MongoDB database |
| `DESTINATION_MONGO_URI` | Yes | Connection string for the destination MongoDB database |
| `BACKUP_SCHEDULE` | Yes | Cron schedule expression for backup frequency |

### Example Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  mongo-backup:
    build: .
    container_name: mongo-backup-service
    environment:
      # Source database (the one you want to backup)
      SOURCE_MONGO_URI: "mongodb://username:password@source-host:27017/database-name"
      
      # Destination database (where backups will be stored)
      DESTINATION_MONGO_URI: "mongodb://username:password@destination-host:27017/backup-database-name"
      
      # Cron schedule (this example runs daily at 2:00 AM)
      BACKUP_SCHEDULE: "0 2 * * *"
    restart: unless-stopped
    volumes:
      # Optional: Mount logs to host for easier access
      - ./logs:/var/log
```

## Configuration Examples

### Backup Schedules (Cron Format)

| Schedule | Description |
|----------|-------------|
| `0 2 * * *` | Daily at 2:00 AM |
| `0 */6 * * *` | Every 6 hours |
| `0 2 * * 0` | Weekly on Sunday at 2:00 AM |
| `0 2 1 * *` | Monthly on the 1st at 2:00 AM |
| `*/15 * * * *` | Every 15 minutes (for testing) |
