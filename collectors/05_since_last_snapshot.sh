#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
SNAP="$ZW_STATE_DIR/${PROJECT_NAME}.last_snapshot"
echo "### 距上次快照的改动统计 ###"
if [ -f "$SNAP" ]; then
  git diff --stat "$(cat "$SNAP")" HEAD 2>/dev/null
else
  echo "(首次快照，无对比基准)"
fi
git rev-parse HEAD > "$SNAP" 2>/dev/null
echo ""
