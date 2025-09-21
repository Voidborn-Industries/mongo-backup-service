#!/usr/bin/env python3
import os
import sys
import time
import subprocess
from datetime import datetime

# Log file path
LOG_FILE = '/var/log/mongo-backup.log'

def log(message):
    """Write message to both console and log file."""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_message = f"[{timestamp}] {message}"
    
    # Print to console
    print(log_message)
    
    # Write to log file
    try:
        with open(LOG_FILE, 'a') as f:
            f.write(log_message + '\n')
            f.flush()
    except Exception as e:
        print(f"Failed to write to log file: {e}")

def backup():
    """Perform MongoDB backup."""
    log("Starting backup...")
    
    source = os.getenv('SOURCE_MONGO_URI')
    dest = os.getenv('DESTINATION_MONGO_URI')
    
    if not source or not dest:
        log("ERROR: SOURCE_MONGO_URI and DESTINATION_MONGO_URI required")
        return False
    
    try:
        # Pipeline: mongodump -> mongorestore
        dump = subprocess.Popen(['mongodump', '--uri', source, '--archive', '--gzip'], 
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        restore = subprocess.Popen(['mongorestore', '--uri', dest, '--archive', '--gzip', '--drop'],
                                  stdin=dump.stdout, stderr=subprocess.PIPE)
        dump.stdout.close()
        
        _, restore_err = restore.communicate()
        _, dump_err = dump.communicate()
        
        if dump.returncode == 0 and restore.returncode == 0:
            log("Backup completed successfully")
            return True
        else:
            log("Backup failed")
            if dump_err: log(f"mongodump error: {dump_err.decode().strip()}")
            if restore_err: log(f"mongorestore error: {restore_err.decode().strip()}")
            return False
            
    except Exception as e:
        log(f"Backup failed: {e}")
        return False

def main():
    # Test mode
    if len(sys.argv) > 1 and sys.argv[1] == 'test':
        backup()
        return
    
    # Get schedule interval in minutes (default: 1440 = daily)
    interval = int(os.getenv('BACKUP_INTERVAL_MINUTES', '1440'))
    
    log(f"MongoDB Backup Service started - running every {interval} minutes")
    
    while True:
        backup()
        log(f"Next backup in {interval} minutes...")
        time.sleep(interval * 60)

if __name__ == "__main__":
    main()
