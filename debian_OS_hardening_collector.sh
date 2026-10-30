#!/usr/bin/env bash
# HPE Morpheus Demo - Task 1: Debian 13 (Trixie) OS Prep & Baseline
set -euo pipefail

STAGING_DIR="/tmp/morpheus_demo"
BASELINE_FILE="${STAGING_DIR}/os_baseline.json"

echo "=== [Task 1] Starting Debian 13 OS Preparation ==="
mkdir -p "$STAGING_DIR"
chmod 755 "$STAGING_DIR"

# 1. Ensure Python 3.13 and core utilities are present
export DEBIAN_FRONTEND=noninteractive
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python3..."
    apt-get update -qq && apt-get install -y -qq python3
fi

PY_VER=$(python3 --version | awk '{print $2}')
KERNEL_VER=$(uname -r)
UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)
HOSTNAME_VAL=$(hostname -f 2>/dev/null || hostname)

# 2. Configure a Demo MOTD Banner
cat <<EOF > /etc/motd
======================================================================
  Managed by HPE Morpheus Enterprise
  OS: Debian GNU/Linux 13 (Trixie) | Kernel: ${KERNEL_VER}
  Python Runtime: ${PY_VER}
  Provisioned Host: ${HOSTNAME_VAL}
======================================================================
EOF
echo "[OK] Configured /etc/motd banner."

# 3. Export baseline metrics for Task 2 (Python)
cat <<EOF > "$BASELINE_FILE"
{
  "hostname": "${HOSTNAME_VAL}",
  "kernel": "${KERNEL_VER}",
  "uptime_seconds": ${UPTIME_SEC},
  "detected_python": "${PY_VER}",
  "motd_configured": true,
  "timestamp_utc": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "[OK] Baseline telemetry written to ${BASELINE_FILE}"
echo "=== [Task 1] Completed Successfully ==="
