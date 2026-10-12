# 学习交接记录

更新日期：2026-10-12。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 主题：简单 KV Cache 增量计算；对应原始要求“题目二 → 5 → 方向 A”第 2、3 项。
- 产物：software/kv_cache.py 新增预分配 K/V 缓存、逐步输出比较与计数；software/README.md 记录设计、三 Token 例子及运行方式；学习任务规划与进度.md 分开记录助手运行与学习者独立验收。
- 验证：python software/kv_cache.py 在 Python 3.14.6、NumPy 2.4.6 下 PASS，逐步与最后位置最大误差均 0.0；D:/python/python.exe software/kv_cache.py 在 Python 3.13.3、NumPy 2.4.6 下 PASS，逐步误差约 2.22e-16、最后位置误差约 6.94e-17。X(3,4) 缓存版每步 K/V 元素数 [8,8,8]、累计 24、重复 0；重算版 [8,16,24]、累计 48、重复 24。
- 未解决：学习者尚未独立运行或解释缓存与重算数据流；因果掩码、QKV 计时方法和基础 Transformer 独立验收仍缺证据。缓存字节数和实际时间尚未报告。
- 下一步：验收第 2 步缓存内容与元素数；按原始公式估算缓存容量，并分别测量两版实际时间。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py、software/qkv_benchmark.py、software/causal_attention.py、software/kv_recompute.py 与 software/kv_cache.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

KV Cache 与逐 Token 重算的数值比较已运行；下一步验收第 2 步缓存内容并统计容量和实际时间。因果掩码、重算数据流、QKV 计时方法和基础 Transformer 的独立验收继续保留。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
