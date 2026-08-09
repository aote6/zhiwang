# 蛛网 (Zhiwang) 项目状态文档

本文档是蛛网自身的状态记录。蛛网是独立项目，不属于灵体或无界。

## 这是什么

一个运行在 Termux 里的轻量快照工具，解决"每次开新AI对话都要手动解释项目现状"的沟通成本问题。核心设计原则：只输出机器能无损、无需解读就直接提取的信息（git状态、commit log、文件树、STATUS.md摘录），不做任何理解/总结/分析，因为这类工作本身需要被解释，等于把沟通成本转移了一层而不是消除。这条原则是从另一个失败工具 sms（试图自动分析代码结构关系，结果自己变得比直接沟通代码更难解释）反推出来的，之后不要往这个方向走回头路。

## 使用方式

- 每个已注册项目对应一个快捷别名，在Termux任意目录下输入别名回车即可，例如 lt（灵体）、wj（无界）。
- 输出直接复制粘贴给新的AI对话开头，不需要额外解释。
- 新增项目：zw add 别名 项目绝对路径，然后 source ~/.bashrc 生效。脚本本身和已有collector都不需要为新项目改动。
- 查看已注册项目：zw list

## 目录结构

- core/snapshot.sh : 唯一调度入口，只负责依次运行所有collector，不含具体采集逻辑
- collectors/*.sh : 每个文件是一条独立的信息采集规则，互不依赖，新增能力只加新文件
- bin/zw : 管理命令，支持 add/list/run
- bin/bashrc_snippet.sh : .bashrc里蛛网配置段的备份，换机或重装Termux时直接cat追加回.bashrc即可恢复
- state/ : 每个项目的上次快照commit号，用于计算增量diff，纯缓存，可随时删除重建
- projects.conf : 别名到路径的映射表，唯一需要手动维护的文件
- STATUS.md : 本文件

## 重要环境约束（踩过的坑）

- storage/shared/ 是Termux通过FUSE挂载的安卓共享存储，不支持unix执行权限（chmod +x 在这里不会生效，ls -l 显示的权限永远是 rw 开头）。所以蛛网所有脚本一律靠 bash 脚本路径 显式调用，绝不依赖 -x 判断或者直接执行脚本本身。bin/zw 在 .bashrc 里也是用 alias 显式调用 bash 命令注册的，不是加执行权限后直接调用。
- 长heredoc在Termux里粘贴大段内容、且混杂中文标点时容易中途截断或错位。写文件时优先用Python脚本、三引号字符串来写，跟本项目改Java代码的模式保持一致，不要用heredoc直接塞长中文段落。

## Collector 列表（当前7个，按文件名前缀数字决定执行顺序）

1. 01_status_head.sh : 若项目根目录有STATUS.md，摘取前40行，不生成不总结，纯截取
2. 02_git_status.sh : 未commit的改动，即 git status --short
3. 03_recent_files.sh : 24小时内改动过的源码文件，已排除build/.git/node_modules/.patches
4. 04_commit_log.sh : 最近8条commit
5. 05_since_last_snapshot.sh : 距上次运行以来的diff统计，首次运行显示无对比基准
6. 06_file_tree.sh : 当前源码文件树，同样排除.patches等噪音目录
7. 07_todo_grep.sh : 全项目TODO/FIXME搜索

## 已知限制 / 待改进

- 06_file_tree.sh 如果项目文件量很大，输出可能过长，届时可能需要加深度限制或过滤规则，目前灵体和无界两个项目规模下没出现这个问题。
- 目前只支持git项目，非git目录会跳过对应collector，02/04/05会静默不输出，这是设计内行为不是bug。
- 还没做删除或取消注册项目的命令，目前只能手动编辑 projects.conf 删行。

## 给新会话的行动准则

1. 蛛网本身改动很少，大概率不需要碰代码，只需要知道怎么用（见上面使用方式）。
2. 如果要新增collector，新建一个 collectors/编号_名称.sh 文件即可，不改 core/snapshot.sh，也不改已有collector。
3. 如果要新增项目，用 zw add，不要手改 projects.conf 之外的任何文件。
4. 写本文件或任何蛛网脚本时，优先用Python脚本三引号字符串分段写入，不要用长heredoc直接塞中文段落，避免粘贴截断。

## 2026-08-09 06_file_tree.sh 修复

- **问题**：Forge 项目快照 file_tree 膨胀（886个文件），因为 .forge 目录未被排除，导致 Planner prompt 超过 32000 字符。
- **修复**：06_file_tree.sh 新增 `-path './.forge'` 排除规则。
- **结果**：Forge 项目 file_tree 从 886 降至 124。
- **定位**：zhiwang 职责是"全量呈现项目现状"，不做任务相关性筛选——后者是调用方（Forge Planner）的职责。

## 2026-08-09 06_file_tree.sh 重构：从手动排除改为 git ls-files

- **之前**：`find` + 手动 `-prune` 排除列表（`.git`/`.forge`/`__pycache__` 等），每个项目新增噪音目录需手动加规则。
- **现在**：优先使用 `git ls-files`，自动遵从项目 `.gitignore`。非 git 仓库退化到 `find` + 基础排除。
- **效果**：排除规则的权威从 zhiwang 转移到各项目自己的 `.gitignore`，不再需要跨项目同步维护排除列表。
