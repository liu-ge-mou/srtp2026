# 学习交接记录

更新日期：2026-10-12。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 主题：逐 Token 解码中每步重算历史 K/V 的基线；对应原始要求“题目二 → 5 → 方向 A”第 1 项。
- 产物：software/kv_recompute.py 新增重算函数、手算例子与检查；software/README.md 记录设计顺序、形状、运行命令和计数公式；学习任务规划与进度.md 将基线代码运行与学习者独立验收分开。
- 验证：python software/kv_recompute.py 在 Python 3.14.6、NumPy 2.4.6 下 PASS，最大绝对误差 0.0；D:/python/python.exe software/kv_recompute.py 在 Python 3.13.3、NumPy 2.4.6 下 PASS，最大绝对误差 1.7763568394002505e-15。固定 X(3,4) 每步 K/V 投影输出元素数 [8,16,24]，累计 48、只算一次 24、重复 24。
- 未解决：学习者尚未独立运行或解释本课基线；因果掩码手算、QKV 计时方法及基础 Transformer 独立验收仍缺证据。缓存版及两版耗时比较未实现。
- 下一步：验收第 2 步的 history、Q/K/V 形状与重复元素数；实现 KV Cache 增量计算并逐步比较输出。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py、software/qkv_benchmark.py、software/causal_attention.py 与 software/kv_recompute.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

逐 Token 重算基线已运行；下一步验收学习者对第 2 步数据流与重复元素数的独立解释，再实现 KV Cache 并与基线比较。因果掩码、QKV 计时方法和基础 Transformer 的独立验收继续保留。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
