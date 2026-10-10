# srtp2026 学习仓库

本仓库保存[原始实验要求](脉动阵列硬件与%20Transformer%20软件.md)、[学习任务规划与进度.md](学习任务规划与进度.md)、[双电脑协作规则](WORKFLOW.md)、[最近交接记录](SESSION_HANDOFF.md)及方向 A/B 的硬件源码快照。`[x]` 只代表有可核对的完成依据；未勾选代表待做或待验证。

## 新电脑首次使用

安装 Git、Vivado 2018.2（或能打开相同 Verilog 工程的版本）及软件实验所需 Python。然后执行：

```powershell
git clone https://github.com/liu-ge-mou/srtp2026.git
cd srtp2026
git status
```

在此目录打开 Codex，先读取 `AGENTS.md`、原始要求、任务清单、交接记录和[协作规则](WORKFLOW.md)。硬件源码在 `hardware/direction_a/`、`hardware/direction_b/`；各目录的 `create_project.tcl` 可重建 Vivado 工程，具体命令见[硬件说明](hardware/README.md)。软件实现尚未创建。

## 日常交接

开始前执行 `git pull --rebase origin main`；结束时提交本次源码、任务状态和交接记录，再执行 `git push origin main`。只有推送成功，另一台电脑才能看到这次进度。并行工作使用分支和 Pull Request；冲突处理及验收规则见 `WORKFLOW.md`。

旧工程和本仓库中的源码快照是不同位置。从现在起，把本仓库作为共同维护的源码位置；旧目录仅供查阅和比对。仓库不包含 Vivado 缓存、旧综合检查点或此前的完整仿真日志。
