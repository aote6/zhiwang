#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
echo "### 未commit的改动 ###"
git status --short
echo ""
