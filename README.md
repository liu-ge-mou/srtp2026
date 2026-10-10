# 脉动阵列与 Transformer 学习同步

本仓库以[学习任务规划与进度.md](学习任务规划与进度.md)为两台电脑共用的进度清单。`[x]` 仅表示已有可核对的完成证据；每次更新应同时写明相关文件、运行结果或尚未验证的限制。

## 两台电脑的工作顺序

首次使用时，在另一台电脑克隆 GitHub 仓库，并在克隆目录中打开 Codex。开始工作前运行 `git pull --rebase origin main`，让 Codex 读取最新清单和 `AGENTS.md`。结束时更新清单及交接记录，再运行：

```powershell
git add 学习任务规划与进度.md SESSION_HANDOFF.md
git commit -m "docs: 更新学习进度与交接记录"
git push origin main
```

在另一台电脑开始前，确认本次提交已推送成功。两台电脑若同时处理同一任务，分别使用分支（如 `pc-a/transformer-block`、`pc-b/conv-check`），完成后通过 GitHub 合并，避免同时改写主分支的同一清单。

## 工程文件范围

当前仓库只同步学习清单及交接说明。方向 A 的 Vivado 工程和方向 B 的 `maidong` 工程位于本机其他目录，清单里的绝对路径只是历史定位记录，克隆后不会自动出现。要在另一台电脑继续修改 RTL 或运行 Vivado，需将可复现的源码、testbench 和必要工程配置另行纳入版本控制；不要上传生成缓存、个人凭据或大量仿真输出。

若克隆目录也位于 OneDrive 内，以 Git 提交和拉取为协作依据，避免 OneDrive 同步尚未完成时让两台电脑同时修改同一工作树。
