# 学习交接记录

更新日期：2026-10-19。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 日期/主题：2026-10-19，KV Cache 容量与完整解码时间；对应原始要求“题目二 → 5 → 方向 A”第 4、5 项。
- 产物：software/kv_benchmark.py；software/kv_cache.py 新增 cache_bytes 元数据；software/results/kv_benchmark_2026-10-19.md 记录原始分组测量、输入和环境；README 与进度同步更新。
- 验证：D:/python/python.exe software/kv_benchmark.py（Python 3.13.3、NumPy 2.4.6、scipy-openblas）和 python software/kv_benchmark.py（Python 3.14.6、NumPy 2.4.6、mkl-sdl）依次运行，均 PASS。前者 (3,4) 重算/缓存为 0.040355/0.042925 毫秒/整段，(128,64) 为 4.077775/2.221130；后者分别为 0.045335/0.047575、5.313685/2.664595。容量 192 / 131072 字节，均与缓存数组 nbytes 相等。
- 适用边界：两版计时包含完整函数与统计，缓存每次重新分配；数组字节不代表进程峰值内存；较大规模为额外对照。小例子缓存略慢、大例子较快，不能证明固定加速。
- 未解决：学习者独立容量手算、计时边界解释和运行仍缺证据；此前基础、QKV、因果掩码与缓存数据流独立验收项保留。
- 同步：课前两次 git pull 均连接失败；当时依据干净本地 main 9e8b03d 工作，未确认远端最新提交；结束时拉取到 cfa5a24，冲突仅涉及两份教学记录，已保留 2026-10-18 续讲内容及第 3 步独立推导待验收。
- 推送状态：本课成果已在本地提交；合并远端 cfa5a24 后的推送多次因连接重置或无法连接 github.com:443 失败，尚未确认远端收到本轮成果。下一次先核对并完成同步。
- 下一步：保留二维例子第 3 步缓存、分数、权重和计数的独立推导；核对容量和计时独立解释，再整理整体复现与验收。

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

KV Cache 数值、容量与完整解码计时已有助手运行证据；下一步核对学习者独立解释并整理整体复现。因果掩码、缓存/重算数据流、计时方法和基础 Transformer 的独立验收继续保留。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
