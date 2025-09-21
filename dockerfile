# Use the official MongoDB image which has the necessary tools
FROM mongo:latest

# Install Python and pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create log directory
RUN mkdir -p /var/log && touch /var/log/backup.log

# Create a directory for our scripts
WORKDIR /app

# Copy the Python backup service
COPY backup_service.py .

# Make the script executable
RUN chmod +x backup_service.py

# Set the entrypoint to our Python service
ENTRYPOINT ["python3", "/app/backup_service.py"]

# Default command (can be overridden)
CMD []
