import subprocess, os, ast, sys

project_path = os.environ.get("PROJECT_PATH", ".")
os.chdir(project_path)

def get_uncommitted_files():
    try:
        r = subprocess.run(["git", "status", "--short"], capture_output=True, text=True, timeout=5)
        if r.returncode != 0:
            return []
        files = []
        for line in r.stdout.splitlines():
            parts = line.strip().split(maxsplit=1)
            if len(parts) == 2:
                files.append(parts[1])
        return files
    except Exception:
        return []

files = get_uncommitted_files()
if not files:
    sys.exit(0)

py_files = [f for f in files if f.endswith(".py") and os.path.exists(f)]
java_files = [f for f in files if f.endswith(".java") and os.path.exists(f)]

if not py_files and not java_files:
    sys.exit(0)

print("### 未commit文件的语法健康检查 ###")

for f in py_files:
    try:
        src = open(f, encoding="utf-8").read()
        ast.parse(src)
        print(f"[OK]   {f}  (Python语法通过)")
    except SyntaxError as e:
        print(f"[FAIL] {f}  Python语法错误: 第{e.lineno}行 {e.msg}")

for f in java_files:
    try:
        src = open(f, encoding="utf-8").read()
        opens = src.count("{")
        closes = src.count("}")
        if opens == closes:
            print(f"[OK]   {f}  (括号平衡: {{ {opens} }} {closes})")
        else:
            print(f"[FAIL] {f}  括号不平衡: {{ {opens} }} {closes}")
    except Exception as e:
        print(f"[FAIL] {f}  读取失败: {e}")

print("")
