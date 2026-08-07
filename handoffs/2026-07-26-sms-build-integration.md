# SMS: main.py 接入 build/ 增量构建引擎

## 背景
承接同日早些时候的"sms结构性清理"交接（归档assembly/pipeline/planner/generator，
删core/module.py，合并state/quality_state，verifier.py拆成定界契约）。
本轮目标：main.py 从"手写全量重编循环"换成调用 build/driver.py
（指纹+缓存+并行+journal 的真实增量构建引擎）。

## 做了什么
- 新建 sms_build_adapters.py：BackendAdapter（把PythonBuilder.build()适配
  成BuildExecutor期待的backend.emit()接口）+ SimplePackager（占位打包器）
- 重写 resolver/gap_resolver.py：去掉对 assembly.AssemblyPlan 的依赖，
  改为直接扫描 build.BuildGraph 节点名找缺失模块；顺带修了 summary()
  里引用已删字段 m.state 的 bug（改成 m.quality_state）
- 重写 main.py：知识图谱部分保留作叙事展示，不再经assembly中转；
  BuildGraph节点 = 知识图谱MODULE节点名 ∪ registry已注册模块名（这样
  GestureDetector依然会被判定为gap并自动生成TODO模块，行为和老代码一致）；
  依赖边从module.submodules读；构建改用BuildScheduler+BuildExecutor+BuildDriver；
  新增了构建前的invariants完整性检查打印
- 修复 core/__init__.py：删掉的 core/module.py 的导入改为从 module 包导入
- 修复 build/executor.py：artifact.path（Path对象）强制转str，防止
  JSON序列化缓存时崩溃

## 做了但没解决、留给以后的
1. IROptimizer 被搁置了：BuildExecutor内部只调用compiler.compile()，没有
   optimize步骤。要恢复这个特性有两个方向：a) 给IRCompiler包一层，compile()
   内部自动跑optimizer；b) 改build/executor.py加一个可选optimizer钩子。
   没有为了保留这个可选特性去动核心构建引擎。
2. build/driver.py 有个真实小缺口：缓存命中的任务不写入driver.results，
   main.py里在外面补了一次兜底校验(遍历registry+cache.get)，没有改driver.py
   本身。如果以后要动driver.py，这个逻辑应该收回到里面去。
3. SimplePackager是占位实现，不生成真实.smspkg格式，直接返回artifact路径。
   build/_archive/build_artifacts/calculator.smspkg 里有个真实格式的例子，
   如果以后要做真打包可以参考。
4. main.py里"知识图谱MODULE节点 ∪ registry模块名"这个并集写法是为了保留
   老demo"GestureDetector自动被识别为gap"的行为，但这只是demo数据里
   凑巧对得上，不是通用机制——如果以后知识图谱节点名和真实模块名不一致，
   这个gap检测会失效。这是能力边界，不是bug。

## state="ready"/"draft"/"todo" 映射表（如果还有别处这么写，照这个改）
- "ready" -> QualityState.PASSED
- "draft" -> QualityState.BLANK
- "todo"  -> QualityState.PENDING（gap_resolver本来就这么用）

## 验证方式
cd ~/sms && python main.py
应该能看到：知识图谱打印 -> gap resolved GestureDetector -> 定界完整性检查
（KeyboardRenderer通过，PinyinEngine和GestureDetector因缺capability/contract不通过，
这是预期行为，不是bug）-> 构建执行 -> journal摘要 -> 运行时加载验证 -> 完成计数
