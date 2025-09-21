# MongoDB Backup Service

A simple Python service runs on docker that backs up MongoDB databases using `mongodump` and `mongorestore`.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SOURCE_MONGO_URI` | Yes | Connection string for the source MongoDB database |
| `DESTINATION_MONGO_URI` | Yes | Connection string for the destination MongoDB database |
| `BACKUP_INTERVAL_MINUTES` | No | Backup interval in minutes (default: 1440 = daily) |

### Example Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  mongo-backup:
    build: .
    container_name: mongo-backup-service
    environment:
      SOURCE_MONGO_URI: "mongodb://user:pass@source:27017/sourcedb"
      DESTINATION_MONGO_URI: "mongodb://user:pass@dest:27017/backupdb"
      BACKUP_INTERVAL_MINUTES: "1440"  # Daily (24 hours)
    volumes:
      - ./logs:/var/log  # Mount logs directory for persistence
    restart: unless-stopped
```
