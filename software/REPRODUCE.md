# Transformer 软件实验复现与验收

本文件对应学习清单“整理可复现运行方式、种子、版本及结果”，覆盖原始要求“题目二”第 3、4 节和第 5 节方向 A。命令均从仓库根目录执行；软件计算实现未在本轮修改。

## 环境与输入

本轮完整复现使用 Python 3.13.3、NumPy 2.4.6、scipy-openblas。此前 Python 3.14.6、NumPy 2.4.6、mkl-sdl 的运行证据见 README 和容量计时记录。requirements.txt 固定 NumPy 版本；相同版本号不保证 BLAS、线程、CPU 或运行时间相同。

在目标 Python 环境中核对版本和解释器路径：

    python -c "import sys, numpy as np; print(sys.executable); print(sys.version); print(np.__version__)"

新环境的依赖安装命令为 python -m pip install -r software/requirements.txt。本轮使用已安装的 NumPy，未重新安装依赖。用 python -m pip 确保 pip 属于所选 Python；普通运行模式保留脚本中的 assert 检查。

固定输入也包含生成方式，而不只有种子：

- 基础、融合、因果注意力、重算与缓存示例复用 make_example()：default_rng(0)、X(3,4)、四个 (4,4) 注意力权重及原有 FFN 权重，默认 float64。
- 二维手算辅助例子为 X=[[1,0],[0,1],[1,1]]、四个单位权重。
- QKV 计时使用独立 default_rng(0)，先生成 X(128,64)，再生成三个 (64,64) 权重；Wqkv 在计时前拼接。
- KV 容量计时的小例子复用 make_example；额外 (128,64) 例子先生成 X，再生成四个正态权重并除以 sqrt(64)，均为 float64。
- 改变随机数生成调用顺序或权重缩放，会改变输入；只固定种子不足以约束所有这些条件。

## 一次完整运行

PowerShell 中依次运行；遇到第一个非零退出码立即停止，保留出错脚本的完整输出：

    $env:PYTHONIOENCODING = "utf-8"
    $studyScripts = @(
        "transformer_numpy.py",
        "qkv_fusion.py",
        "qkv_benchmark.py",
        "causal_attention.py",
        "kv_recompute.py",
        "kv_cache.py",
        "kv_benchmark.py"
    )
    foreach ($studyScript in $studyScripts) {
        python "software/$studyScript"
        if ($LASTEXITCODE -ne 0) {
            throw "脚本失败: $studyScript"
        }
    }

数组固定运行顺序；foreach 一次执行一个脚本，计时任务不会并行争用 CPU；LASTEXITCODE 检查刚完成的进程退出码。每个脚本自身的 main() 运行计算和断言，最后打印对应 PASS。这个流程复用已有脚本，不增加新的计算实现。

## 每个结果与谁比较

| 脚本 | 对应原始要求 | 检查对象和预期 |
|---|---|---|
| transformer_numpy.py | 题目二第 3 节实现与验证 | H2(3,4)，P 行和为 1、LayerNorm 均值近 0、有限值及输入扰动 |
| qkv_fusion.py | 第 4 节第 1、2 项 | 同一输入和权重的 Q/K/V、注意力输出、完整 H2 分别与分开版比较；投影理论 MAC 同为 144 |
| qkv_benchmark.py | 第 4 节第 3～5 项 | X(128,64)，先核对 Q/K/V；再报告投影中位时间，理论 MAC 同为 1,572,864 |
| causal_attention.py | 第 5 节方向 A 的因果前提 | 未来权重为 0；前缀输出一致；未来扰动不影响过去 |
| kv_recompute.py | 第 5 节方向 A 第 1 项 | 每步当前输出与整段因果注意力对应行比较；K/V 投影元素 [8,16,24] |
| kv_cache.py | 第 5 节方向 A 第 2、3 项 | 缓存输出与重算及整段因果注意力比较；K/V 投影元素 [8,8,8] |
| kv_benchmark.py | 第 5 节方向 A 第 4、5 项和清单计时项 | 投影计数、缓存 nbytes、两版输出；再报告完整解码时间 |

比较数值前先确认四件事：同一 X、同一权重、同一计算规则、同一输出位置。

基础脚本的 P 未加因果掩码，本轮第一行约 [0.3842,0.3004,0.3153]；因果脚本第一行 [1,0,0]，变化来自读取范围不同。KV 脚本输出是注意力经 Wo 的结果；基础脚本 H2 还经过残差、LayerNorm 和 FFN。二者形状均为 (3,4)，形状相同不足以要求数值相等。

打印值只保留部分小数。例如第一行 0.3842+0.3004+0.3153=0.9999，原始未四舍五入的 P 行和通过容差检查。数值验收依据脚本对原数组的断言，不能只按屏幕显示的小数相加。最大绝对误差接近机器舍入量时，用脚本的 allclose 容差判定。

## 单位与证据

- QKV 计时：微秒/一次投影调用，含融合切分，不含预先拼接。
- KV 计时：毫秒/完整序列的全部 T 步，含缓存分配/写入、注意力、输出组装和统计。
- 缓存容量：K_cache.nbytes + V_cache.nbytes，仅数组数据区域；(3,4)、float64 为 192 字节，(128,64) 为 131072 字节。
- 理论 MAC、投影输出元素数、字节与时间分别报告，不能互相代替。
- PASS 表示对应断言通过；时间值不设必须与旧日志相同的标准，也不要求优化版更快。

## 本轮证据

[完整运行原始输出](results/reproduce_2026-10-19.txt) 记录源码基线 ff0fd2c、每个脚本输出及退出码。源码基线指运行时提交，后续本次文档提交未改变这些计算脚本。

2026-10-19，七个脚本均退出码 0，SUITE_EXIT_CODE 为 0。QKV 分开/融合为 47.746/60.112 微秒。KV 重算/缓存在 (3,4) 为 0.040790/0.043740 毫秒，在 (128,64) 为 4.161665/2.252785 毫秒。数值、形状、容量和投影计数检查均通过。与此前时间不同，保留为新的测量，未覆盖旧记录。

[此前容量与计时记录](results/kv_benchmark_2026-10-19.md) 保留两个 Python/BLAS 环境的单独测量。

## 学习者独立验收记录

以上属于助手执行证据。学习者提交自己的命令、Python/NumPy/BLAS 信息、输出和解释后，再逐项验收。

当前待独立填写的二维例子：X=[[1,0],[0,1],[1,1]]、四个权重均为单位阵，推导第 3 步：
- 当前 q 与有效 K/V 缓存的形状和内容；
- 分数、softmax 权重、最终注意力输出；
- 本步新计算 K/V 元素数、前三步累计数；
- float64 下两块缓存的容量；
- 输出应与哪一段基线代码比较，以及比较理由。

此前基础手算、完整 Transformer、QKV 拼接及计时方法解释等未验收项继续以学习清单为准。本次完整运行不替代学习者掌握。
