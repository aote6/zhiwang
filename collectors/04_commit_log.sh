#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
echo "### 最近8次commit ###"
git log --oneline -8 2>/dev/null
echo ""
