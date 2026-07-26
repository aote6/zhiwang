#!/data/data/com.termux/files/usr/bin/bash
# 06_file_tree.sh - 当前源码文件树，排除噪音目录

cd "$PROJECT_PATH" || exit 0
echo "### 源码文件树 ###"
find . \( \
  -path './.git' -o \
  -path './_archive' -o \
  -path './dist' -o \
  -name '__pycache__' -o \
  -path './node_modules' -o \
  -path './.patches' -o \
  -path './build' -o \
  -path './.smsrepo' \
\) -prune -o \( -name "*.java" -o -name "*.py" -o -name "*.json" \) -type f -print | sort
echo ""
