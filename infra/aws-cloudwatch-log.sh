#!/bin/bash
# EchoForge AWS CloudWatch Log Integration
# Pushes workflow logs to CloudWatch Logs for SIEM integration

set -euo pipefail

# Configuration
LOG_GROUP_NAME="${LOG_GROUP_NAME:-/echoforge/workflows}"
LOG_STREAM_NAME="${LOG_STREAM_NAME:-backup-$(date +%Y%m%d)}"

# Required environment variables
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID must be set}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY must be set}"
: "${AWS_REGION:?AWS_REGION must be set}"

echo "========================================="
echo "EchoForge CloudWatch Log Integration"
echo "========================================="
echo "Log Group: ${LOG_GROUP_NAME}"
echo "Log Stream: ${LOG_STREAM_NAME}"
echo "Region: ${AWS_REGION}"
echo "========================================="

# Create log group if it doesn't exist
echo "Ensuring log group exists..."
aws logs create-log-group \
  --log-group-name "${LOG_GROUP_NAME}" \
  --region "${AWS_REGION}" 2>/dev/null || true

# Create log stream if it doesn't exist
echo "Ensuring log stream exists..."
aws logs create-log-stream \
  --log-group-name "${LOG_GROUP_NAME}" \
  --log-stream-name "${LOG_STREAM_NAME}" \
  --region "${AWS_REGION}" 2>/dev/null || true

# Read log message from stdin or use default message
if [ -t 0 ]; then
  # No input on stdin, use default message
  LOG_MESSAGE="EchoForge workflow executed at $(date -Iseconds)"
else
  # Read from stdin
  LOG_MESSAGE=$(cat)
fi

# Prepare log event
TIMESTAMP=$(date +%s%3N)  # milliseconds since epoch

# Put log events to CloudWatch
echo "Sending log event to CloudWatch..."
aws logs put-log-events \
  --log-group-name "${LOG_GROUP_NAME}" \
  --log-stream-name "${LOG_STREAM_NAME}" \
  --log-events timestamp="${TIMESTAMP}",message="${LOG_MESSAGE}" \
  --region "${AWS_REGION}" \
  --no-cli-pager > /dev/null

echo "========================================="
echo "Log event sent successfully!"
echo "========================================="

# Optional: Query recent logs
echo ""
echo "Recent log entries:"
aws logs tail "${LOG_GROUP_NAME}" \
  --since 1h \
  --format short \
  --region "${AWS_REGION}" 2>/dev/null | tail -5 || echo "No logs found (this is normal for first run)"
