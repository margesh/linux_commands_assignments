#!/bin/bash
# /backups/nginx_backup.sh
# Nginx backup for Mike (config + docroot)
set -euo pipefail

BACKUP_DIR="/backups"
DATE=$(date +"%F")
OUTFILE="$BACKUP_DIR/nginx_backup_${DATE}.tar.gz"
LOGFILE="$BACKUP_DIR/nginx_backup_${DATE}.log"

# detect config path
if [ -d "/etc/nginx" ]; then
  NGINX_CONF="/etc/nginx"
else
  echo "Nginx config directory not found" >&2
  exit 1
fi

DOC_ROOT="/usr/share/nginx/html"

{
  echo "=== Nginx Backup Started: $(date) ==="
  echo "Config: $NGINX_CONF"
  echo "Doc root: $DOC_ROOT"
  echo "Archive: $OUTFILE"
  echo

  tar -czf "$OUTFILE" "$NGINX_CONF" "$DOC_ROOT"
  echo "Archive created: $OUTFILE"
  echo
  echo "Verifying archive contents (first 50 lines):"
  tar -tzf "$OUTFILE" | head -n 50
  echo
  echo "=== Nginx Backup Completed: $(date) ==="
} >"$LOGFILE" 2>&1

# rotate - keep last 8
ls -1tr "$BACKUP_DIR"/nginx_backup_*.tar.gz 2>/dev/null | head -n -8 | xargs -r rm --
