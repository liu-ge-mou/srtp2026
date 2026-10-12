# 学习交接记录

更新日期：2026-10-12。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 主题：因果掩码与单层因果自注意力；按原始要求的 KV Cache 实验先建立因果计算基线。
- 产物：software/causal_attention.py 新增实现与自检；software/README.md 写明设计、三 Token 手算例子及运行命令；学习任务规划与进度.md 分开记录理解和代码证据。
- 验证：python software/causal_attention.py 在 Python 3.14.6、NumPy 2.4.6 下 PASS；D:/python/python.exe software/causal_attention.py 在 Python 3.13.3、NumPy 2.4.6 下 PASS。输出 (3,4)，权重约 [[1,0,0],[0.6092,0.3908,0],[0.0533,0.0081,0.9386]]；未来权重零、行和一、前缀一致与未来扰动检查通过。
- 未解决：学习者尚未独立手算、解释或运行本课脚本。QKV 计时方法完整解释、基础 Transformer 练习仍待验收；逐 Token 重算和 KV Cache 尚未实现。
- 下一步：验收第 1 行允许位置和归一化，再实现逐 Token 重算基线，最后比较 KV Cache 增量计算。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py、software/qkv_benchmark.py 与 software/causal_attention.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

因果注意力实现已运行；下一步先验收学习者对掩码位置和第 1 行概率的独立解释，再实现逐 Token 重算与 KV Cache。QKV 计时方法的独立解释继续保留待验收。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
