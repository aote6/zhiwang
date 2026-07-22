# ===== 蛛网 zhiwang =====
ZW_HOME="$HOME/storage/shared/zhiwang"
alias zw='bash "$ZW_HOME/bin/zw"'
if [ -f "$ZW_HOME/projects.conf" ]; then
  while IFS='=' read -r name path; do
    [ -z "$name" ] && continue
    eval "$name() { bash \"\$ZW_HOME/core/snapshot.sh\" \"$path\" \"$name\"; }"
  done < "$ZW_HOME/projects.conf"
fi
