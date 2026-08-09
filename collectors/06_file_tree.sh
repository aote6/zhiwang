#!/data/data/com.termux/files/usr/bin/bash
# 06_file_tree.sh - 当前源码文件树，遵从项目 .gitignore

cd "$PROJECT_PATH" || exit 0
echo "### 源码文件树 ###"

# 优先用 git ls-files（自动遵守 .gitignore）
if git rev-parse --git-dir > /dev/null 2>&1; then
    git -C "$PROJECT_PATH" ls-files -- '*.java' '*.py' '*.json' 2>/dev/null | sort
else
    # 非 git 仓库退化到 find + 基础排除
    find . \( -path './.git' -o -name '__pycache__' -o -path './node_modules' \) -prune -o \( -name "*.java" -o -name "*.py" -o -name "*.json" \) -type f -print | sort
fi
echo ""
