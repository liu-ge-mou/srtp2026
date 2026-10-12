# 学习交接记录

更新日期：2026-10-12。

## 最近一次协同接入

- 日期：2026-10-12。本机项目目录已检出并跟踪 GitHub `main`；旧 Vivado 工程和原有文档保存在仓库外，供后续对照。
- 验证：`git pull --ff-only origin main` 显示 `Already up to date.`，`git status -sb` 显示 `## main...origin/main`。本轮未运行 Python 或 Vivado，也未进行新的课程验收。
- 下一步：继续按下方学习回合记录，先核对 QKV 拼接、切分、MAC 和计时解释；硬件任务以 `hardware/` 为共同源码。

## 最近一次学习回合

- 主题：学习者指出 QKV 性能测量尚未学完；更正此前将助手运行与学习进度混写的记录，从题目二第 4 节计时步骤继续教学。
- 产物：更新 `学习任务规划与进度.md`，将性能测量理解项恢复为 `[ ]`，保留助手脚本运行项的独立证据；本轮继续讲解脚本执行路径并布置独立验收。
- 验证：`git pull --rebase origin main` 显示 Already up to date。默认 `python` 指向失效虚拟环境，两个脚本均未启动；改用 Codex 捆绑 Python 3.12.14、NumPy 2.3.5，运行 `software/qkv_fusion.py` 通过，Q/K/V、注意力和 Block 最大误差均为 0.0；运行 `software/qkv_benchmark.py` 通过，Q/K/V 最大误差 0.0，分开/融合中位时间为 96.431/202.302 微秒每次。未运行 Vivado。
- 未解决：学习者尚未完成性能测量课程及独立解释；QKV 拼接、切分、MAC、基础 Transformer 手算与代码理解也待验收；硬件 A/B 待办不变。
- 下一步：先核对学习者对计时边界、预热、批次平均、中位数和本次结果的解释；再处理 QKV 其余待验收项，随后进入因果掩码、逐 token 推理及 KV Cache。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py 与 software/qkv_benchmark.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

核对学习者对 QKV 拼接、切分、MAC 与计时结果的独立解释；保留基础 Transformer 手算待验收项。随后按清单进入因果掩码与 KV Cache。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
