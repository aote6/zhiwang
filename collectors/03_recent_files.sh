#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
echo "### 24小时内改动的文件 ###"
find . -type f -mtime -1 \( -name "*.java" -o -name "*.py" -o -name "*.json" -o -name "*.md" \) 2>/dev/null | grep -vE "build|\.git|node_modules|\.patches|_archive|dist"
echo ""
