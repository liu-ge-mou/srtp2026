# 学习交接记录

更新日期：2026-10-19。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 日期/主题：2026-10-19，INT8 第 1 课，对应原始题目二第 5 节方向 B 的转换公式及实验计划第 1 步。
- 已讲解：scale 的原单位含义、[-127,127] 对称范围、手算缩放/舍入/反量化、零矩阵处理、NumPy 最近偶数规则及半格误差推导；沿两个函数执行顺序解释代码与检查。
- 产物：software/int8_quantization.py，software/results/int8_quantization_step1.md；计划、README、REPRODUCE 和学习清单同步更新。
- 验证：基线 86ac4c6，课前拉取 Already up to date；D:/python/python.exe 与默认 python 分别为 3.13.3、3.14.6，NumPy 均 2.4.6，运行 software/int8_quantization.py 均 PASS/退出码 0。s=0.01，q=[[-127,24],[50,127]]，重建最大误差约 0.004，半格界 0.005；手算、形状、零矩阵、端点、舍入与输入保持通过。
- 待办：学习者独立理解仍无证据；存储/QKV、完整 Block 对比未实现。此前 Transformer/KV Cache 待验收继续保留。
- 下一步：计划第 2 步，复用 make_example() 的同一 X 和 Wq/Wk/Wv，统计三矩阵、三个 scale 的数据字节，比较三个投影的误差。

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

INT8 第 1 步已由助手实现并运行，下一步进入 software/INT8_EXPERIMENT_PLAN.md 第 2 步存储与 Q/K/V 对比；此前七脚本复现和 KV Cache 独立验收状态保留。因果掩码、缓存/重算数据流、计时方法和基础 Transformer 的独立验收继续保留。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
