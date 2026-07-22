#!/data/data/com.termux/files/usr/bin/bash
ZW_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ZW_STATE_DIR="$ZW_HOME/state"
mkdir -p "$ZW_STATE_DIR"
export PROJECT_PATH="$1"
export PROJECT_NAME="$2"

echo "======== [$PROJECT_NAME] 项目快照 ========"
echo ""
for collector in "$ZW_HOME"/collectors/*.sh; do
  [ -f "$collector" ] && bash "$collector"
done
echo "======== 快照结束 ========"
