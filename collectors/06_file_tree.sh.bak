#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
echo "### 源码文件树 ###"
find . \( -name "*.java" -o -name "*.py" -o -name "*.json" \) 2>/dev/null | grep -vE "build|\.git|node_modules|\.patches"
echo ""
