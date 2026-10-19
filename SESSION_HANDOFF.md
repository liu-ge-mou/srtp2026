# 学习交接记录

更新日期：2026-10-19。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 日期/主题：2026-10-19，用户要求规划 Transformer 软件方向 B 的 INT8 权重量化实验。
- 来源与范围：原始题目二第 5 节方向 B 第 1～4 项及第 6 节。现有 KV Cache 作为已开展方向保留；新增量化计划，未实现量化源码。
- 产物：software/INT8_EXPERIMENT_PLAN.md；README 增加计划入口，学习清单新增量化各待办。
- 方案：三张 (4,4) float64 Wq/Wk/Wv 分别用一个 scale，对称 [-127,127]；处理全零，先 round/clip 再转换类型，反量化到原浮点类型；复制参数字典仅替换三个权重，两路复用同一 transformer_block。
- 预计统计：三矩阵浮点数据 384 字节，INT8 数据 48 字节，加三个 float64 scale 为 72 字节；尚未量化运行，用于后续 nbytes 核对。运行期反量化数组另占空间，不把打包数据当峰值内存。
- 验证与状态：本轮只核对文件和原始要求，未运行 Python/Vivado，量化待实现、误差待实测、学习者理解待验收。中途被用户转向的“序列长度翻倍”仅选题，未完成讲解。
- 下一步：按计划第 1 步手算并实现量化/反量化，再做存储/QKV、完整 Block 与结果分析。原有基础和 KV Cache 独立验收继续保留。

## 上一回合记录（2026-10-18）

- 主题：2026-10-18 续讲当前 `decode_cached`，对应原始要求“题目二 → 5 → 方向 A”第 2、3 项。
- 产物：按源码执行顺序讲解二维例子第 2 步的缓存和输出，说明参数/返回值、预分配、有效前缀、切片、分数与 softmax、输出投影、计数和检查。只更新学习记录，未修改源码。
- 验证：python software/kv_cache.py 在 Python 3.14.6、NumPy 2.4.6 下 PASS，逐步与最后位置最大误差均 0.0；D:/python/python.exe software/kv_cache.py 在 Python 3.13.3、NumPy 2.4.6 下 PASS，逐步误差约 2.22e-16、最后位置误差约 6.94e-17。X(3,4) 缓存版每步 K/V 元素数 [8,8,8]、累计 24、重复 0；重算版 [8,16,24]、累计 48、重复 24。
- 未解决：学习者尚未独立运行或解释缓存与重算数据流；因果掩码、QKV 计时方法和基础 Transformer 独立验收仍缺证据。缓存字节数和实际时间尚未报告。
- 本轮验证：拉取显示 Already up to date，检查源码基线 `9e8b03d`；未运行 Python 或 Vivado，上一条运行结果为此前证据。
- 下一步：验收学习者对二维例子第 3 步缓存、分数、权重及元素数的推导；随后按原始公式估算容量并测量实际时间。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py、software/qkv_benchmark.py、software/causal_attention.py、software/kv_recompute.py、software/kv_cache.py 与 software/kv_benchmark.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

用户当前主线转为 INT8 权重量化实验，下一步从 software/INT8_EXPERIMENT_PLAN.md 第 1 步开始；此前七脚本复现和 KV Cache 独立验收状态保留。因果掩码、缓存/重算数据流、计时方法和基础 Transformer 的独立验收继续保留。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
