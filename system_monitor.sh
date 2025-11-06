#!/bin/bash
LOGFILE="/var/log/system_monitor.log"
{
  echo "=============================="
  echo "Date: $(date)"
  echo "CPU & Memory Usage:"
  top -bn1 | head -n 10
  echo ""
  echo "Disk Usage:"
  df -h
  echo ""
  echo "Top 5 CPU-consuming Processes:"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
  echo ""
  echo "Top 5 Memory-consuming Processes:"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
  echo ""
} >> "$LOGFILE"
