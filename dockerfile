# Use the official MongoDB image which has the necessary tools
FROM mongo:latest

# Update package list and install cron
# Using --no-install-recommends makes the image smaller
RUN apt-get update && apt-get install -y --no-install-recommends cron && rm -rf /var/lib/apt/lists/*

# Create a directory for our scripts
WORKDIR /app

# Copy the backup and entrypoint scripts into the container
COPY entrypoint.sh .
COPY backup.sh .

# Make the scripts executable
RUN chmod +x entrypoint.sh backup.sh

# Set the entrypoint to our custom script
ENTRYPOINT ["/app/entrypoint.sh"]

# The command that will be executed by the entrypoint script
CMD ["cron", "-f"]
