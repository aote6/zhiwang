#!/data/data/com.termux/files/usr/bin/bash
cd "$PROJECT_PATH" || exit 0
echo "### TODO/FIXME ###"
grep -rn "TODO\|FIXME" --include="*.java" --include="*.py" . 2>/dev/null \
  | grep -vE "build|node_modules|_archive|dist|__pycache__|\.smsrepo"
echo ""
