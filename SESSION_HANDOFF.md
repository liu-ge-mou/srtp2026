# 学习交接记录

更新日期：2026-10-12。

## 最近一次学习回合

- 主题：重讲 QKV 融合及下一步性能测量；按用户反馈补足推导、代码规划、执行路径和自查。
- 产物：新增 software/qkv_benchmark.py；更新 software/README.md、学习任务规划与进度.md 和本交接记录；修正 WORKFLOW.md 中软件尚未实现的过时表述。
- 验证：python software/qkv_fusion.py 通过，Q/K/V、注意力和 Block 最大误差均为 0.0；python software/qkv_benchmark.py 通过，Q/K/V 最大误差 8.881784197001252e-15，两次运行分开/融合分别为 46.550/29.099 与 44.078/33.469 微秒每次，比值 1.600 与 1.317；Python 3.14.6、NumPy 2.4.6。性能数值只代表本机这两次运行。
- 未解决：学习者尚未独立解释 QKV 拼接、切分、MAC 和计时设计；基础 Transformer 手算与代码理解仍待验收，硬件 A/B 待办不变。
- 下一步：先核对学习者对 QKV 与计时结果的独立理解，再讲因果掩码，随后进入逐 token 推理和 KV Cache。

## 当前状态

- 共用任务以 `学习任务规划与进度.md` 为准。现已复制方向 A/B 的 RTL、testbench 和建工程脚本到 `hardware/`，尚未在新位置运行 Vivado。
- 方向 A 的既有仿真日志记录了两组矩阵检查通过，同时在 `$finish` 后记录异常退出码；最新 RTL 尚缺一次正常结束的完整仿真和重新综合。
- 方向 B 已完成初步源码阅读；数据打包方向、组合逻辑赋值及数值结果仍待验证。
- software/transformer_numpy.py、software/qkv_fusion.py 与 software/qkv_benchmark.py 已在本机运行通过；学习者独立手算和理解项仍待验收。

## 下一步

核对学习者对 QKV 拼接、切分、MAC 与计时结果的独立解释；保留基础 Transformer 手算待验收项。随后按清单进入因果掩码与 KV Cache。若切换到方向 A 或 B，先从 hardware/ 重建 Vivado 工程。

## 每次交接填写

在文件顶部更新日期和“最近一次学习回合”，固定记录主题、产物、验证、未解决事项和下一步。每课结束同时更新任务清单；讲解但未验收时写明“待验收”，不勾选。完成后连同任务清单提交并推送。
