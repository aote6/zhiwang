#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
[ -f STATUS.md ] || exit 0
echo "### STATUS.md 核心结论(前40行) ###"
head -40 STATUS.md
echo ""
