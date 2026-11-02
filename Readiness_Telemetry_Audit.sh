#!/usr/bin/env bash
# HPE Morpheus Demo - Task 2: Pure Bash Readiness & Telemetry Audit
set -euo pipefail

BASELINE_FILE="/tmp/morpheus_demo/os_baseline.json"
REPORT_FILE="/tmp/morpheus_demo/final_audit_report.json"

# Log progress to stderr so stdout remains pure JSON for Morpheus Result parsing
log_info() {
    echo "[Bash-Audit] $1" >&2
}

log_info "Starting Debian 13 system readiness audit..."

# 1. Read OS Release Info
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_PRETTY="${PRETTY_NAME:-Debian GNU/Linux 13 (trixie)}"
    OS_CODENAME="${VERSION_CODENAME:-trixie}"
else
    OS_PRETTY="Unknown Linux"
    OS_CODENAME="unknown"
fi

# 2. Gather CPU, Memory, and Disk Metrics
CPU_COUNT=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)

MEM_TOTAL_KB=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
MEM_AVAIL_KB=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
MEM_TOTAL_MB=$(awk "BEGIN {printf \"%.1f\", ${MEM_TOTAL_KB}/1024}")
MEM_AVAIL_MB=$(awk "BEGIN {printf \"%.1f\", ${MEM_AVAIL_KB}/1024}")

# Get root disk usage percentage (numeric only)
DISK_USED_PCT=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')

# 3. Network Info
FQDN_VAL=$(hostname -f 2>/dev/null || hostname)
PRIMARY_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
PRIMARY_IP=${PRIMARY_IP:-127.0.0.1}

# 4. Verify Task 1 Handoff
if [ -f "$BASELINE_FILE" ]; then
    log_info "Loading Task 1 baseline from ${BASELINE_FILE}"
    TASK1_JSON=$(cat "$BASELINE_FILE")
    TASK1_HANDOFF="true"
else
    log_info "Warning: Task 1 baseline file not found. Using empty baseline."
    TASK1_JSON="{}"
    TASK1_HANDOFF="false"
fi

# 5. Evaluate Compliance Gates
DEBIAN_VERIFIED="false"
[ "$OS_CODENAME" = "trixie" ] && DEBIAN_VERIFIED="true"

DISK_HEALTHY="false"
[ "${DISK_USED_PCT}" -lt 85 ] && DISK_HEALTHY="true"

OVERALL_STATUS="WARNING"
if [ "$DEBIAN_VERIFIED" = "true" ] && [ "$DISK_HEALTHY" = "true" ] && [ "$TASK1_HANDOFF" = "true" ]; then
    OVERALL_STATUS="PASSED"
fi

AUDITED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 6. Build Final JSON Payload
mkdir -p "$(dirname "$REPORT_FILE")"
cat <<EOF > "$REPORT_FILE"
{
  "workflow_status": "${OVERALL_STATUS}",
  "audited_at_utc": "${AUDITED_AT}",
  "compliance_checks": {
    "debian_trixie_verified": ${DEBIAN_VERIFIED},
    "disk_space_healthy": ${DISK_HEALTHY},
    "task1_handoff_success": ${TASK1_HANDOFF}
  },
  "task1_baseline": ${TASK1_JSON},
  "task2_telemetry": {
    "os_pretty_name": "${OS_PRETTY}",
    "os_codename": "${OS_CODENAME}",
    "resources": {
      "cpu_count": ${CPU_COUNT},
      "memory_total_mb": ${MEM_TOTAL_MB},
      "memory_available_mb": ${MEM_AVAIL_MB},
      "root_disk_used_percent": ${DISK_USED_PCT}
    },
    "network": {
      "fqdn": "${FQDN_VAL}",
      "primary_ip": "${PRIMARY_IP}"
    }
  }
}
EOF

log_info "Saved full audit artifact to ${REPORT_FILE}"

# Output clean JSON to stdout for Morpheus Task Results capture
cat "$REPORT_FILE"
