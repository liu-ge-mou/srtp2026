# 硬件源码快照

`direction_a/` 保存 2×2 脉动阵列 RTL 和三个 testbench；`direction_b/` 保存四路卷积 RTL、testbench 及四个算术依赖模块。文件从 2026-10-10 本机现有 Vivado 工程按原始字节复制，尚未在仓库目录重新运行仿真或综合。不要把旧工程日志视为此快照的新验证结果。

两套工程目标器件均为 `xc7a35tcpg236-1`。原工程使用 Vivado 2018.2。切换到对应目录后运行：

```powershell
vivado -mode batch -source create_project.tcl
```

脚本在各自的 `build/` 中生成 Vivado 工程，使用仓库内相对路径。打开 `build/direction_a.xpr` 或 `build/direction_b.xpr` 后分别运行 Behavioral Simulation 和 Synthesis。`build/` 及 Vivado 缓存已忽略；只提交实际修改的 RTL、testbench、脚本和精简结果记录。

方向 B 的 `deps/` 四个文件来自本机 `LENET/Lenet_实验代码/lenet5/src/design/lenet/`，原工程通过跨目录绝对关系引用它们。它们已原样复制以保证另一台电脑可以找到相同模块；其运算行为仍需核查。方向 A 原工程引用旧 `accumulator.dcp` 作增量综合，本仓库没有携带该检查点，生成的新工程不会继续使用它。
