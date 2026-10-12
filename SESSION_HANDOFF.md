# 学习交接记录

更新日期：2026-10-12。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 主题：学习者允许一次连续讲几步，并要求子代理自检；本轮串讲 QKV 计时、因果掩码、KV Cache 原理。
- 产物：两个只读子代理分别检查技术准确性与教学顺序；根据建议补充组内平均/跨组中位数、softmax 前遮盖、K/V 重算与历史读取的区别，更新 `学习任务规划与进度.md`。未修改源码。
- 验证：`git pull --rebase origin main` 显示 Already up to date；本轮已检查三个 `software/` Python 文件源码，未运行 Python 或 Vivado。当前 `self_attention` 无因果掩码，仓库无 KV Cache 实现；此前 QKV 脚本结果不可当成本轮新运行。
- 未解决：三步均只完成讲解，学习者独立练习未提交；QKV 计时、因果掩码、KV Cache 及基础 Transformer 理解继续待验收，硬件 A/B 待办不变。
- 下一步：按三道独立练习逐项反馈，再实现并验证因果注意力与 KV Cache；不要把当前双向 `self_attention` 视为因果实现。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py 与 software/qkv_benchmark.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

核对学习者对 QKV 拼接、切分、MAC 与计时结果的独立解释；保留基础 Transformer 手算待验收项。随后按清单进入因果掩码与 KV Cache。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
