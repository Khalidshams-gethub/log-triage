#!/usr/bin/env bash
# log-triage.sh
# Analyze SSH authentication failures from a log file.

set -euo pipefail

# Default input: change this if your log has a different path/name
INPUT_FILE="${1:-sample_logs/auth.log}"
OUTPUT_DIR="output"
FAILED_LOG="${OUTPUT_DIR}/ssh_failed.log"
SUMMARY_FILE="${OUTPUT_DIR}/summary.txt"

# --- 1. Basic validation ---
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file '$INPUT_FILE' not found." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# --- 2. Extract only failed SSH password attempts ---
# We focus on lines like:
#   Oct  6 07:36:54 localhost sshd[8228]: Failed password for root from 172.20.1.1 port 36195 ssh2
grep "Failed password for" "$INPUT_FILE" | tee "$FAILED_LOG" > /dev/null

# --- 3. Build summary: count failures per user@ip ---
# From each line, we pull:
#   - user after the word "for"
#   - ip   after the word "from"
awk '
  /Failed password for/ {
    user = ""
    ip = ""

    # Find username and IP by scanning fields
    for (i = 1; i <= NF; i++) {
      if ($i == "for") {
        user = $(i+1)
      }
      if ($i == "from") {
        ip = $(i+1)
      }
    }

    if (user != "" && ip != "") {
      key = user "@" ip
      counts[key]++
    }
  }
  END {
    print "Failed SSH login attempts by user@ip:"
    print "====================================="
    for (k in counts) {
      printf "%-25s %d\n", k, counts[k]
    }
  }
' "$FAILED_LOG" | sort -k2 -nr > "$SUMMARY_FILE"

echo "✅ SSH log analysis complete."
echo "   Failed attempts: $FAILED_LOG"
echo "   Summary report:  $SUMMARY_FILE"
