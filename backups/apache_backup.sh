#!/bin/bash
# Apache Backup Script for Sarah
# Runs every Tuesday at 00:00 (12:00 AM)
# Saves backups under /backups/apache_backup_YYYY-MM-DD.tar.gz

set -euo pipefail

BACKUP_DIR="/backups"
DATE=$(date +"%F")
OUTFILE="$BACKUP_DIR/apache_backup_${DATE}.tar.gz"
LOGFILE="$BACKUP_DIR/apache_backup_${DATE}.log"

# Detect correct Apache config directory (RHEL uses /etc/httpd, Ubuntu uses /etc/apache2)
if [ -d "/etc/httpd" ]; then
  APACHE_CONF="/etc/httpd"
elif [ -d "/etc/apache2" ]; then
  APACHE_CONF="/etc/apache2"
else
  echo "Apache config directory not found!" >&2
  exit 1
fi

DOC_ROOT="/var/www/html"

# Start logging
{
  echo "=== Apache Backup Started: $(date) ==="
  echo "Configuration Directory: $APACHE_CONF"
  echo "Document Root: $DOC_ROOT"
  echo "Target Archive: $OUTFILE"
  echo

  # Create compressed backup
  tar -czf "$OUTFILE" "$APACHE_CONF" "$DOC_ROOT"
  echo "Backup archive created successfully."
  echo

  # Verify archive integrity
  echo "Verifying backup contents (first 20 entries):"
  tar -tzf "$OUTFILE" | head -n 20
  echo

  echo "=== Apache Backup Completed: $(date) ==="
} >"$LOGFILE" 2>&1

# Keep only the last 8 backups
ls -1tr "$BACKUP_DIR"/apache_backup_*.tar.gz 2>/dev/null | head -n -8 | xargs -r rm --

