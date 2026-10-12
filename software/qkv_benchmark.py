"""比较 QKV 三次投影与一次融合投影的运行时间。"""

import sys
from time import perf_counter_ns

import numpy as np

from qkv_fusion import project_qkv_fused


def project_qkv_separate(x, Wq, Wk, Wv):
    """三次矩阵乘法，作为融合实现的计时基线。"""
    return x @ Wq, x @ Wk, x @ Wv


def time_batch(function, calls):
    """连续执行 calls 次，返回每次调用的平均纳秒数。"""
    start = perf_counter_ns()
    for _ in range(calls):
        function()
    return (perf_counter_ns() - start) / calls


def main():
    rng = np.random.default_rng(0)
    x = rng.normal(size=(128, 64))
    Wq = rng.normal(size=(64, 64))
    Wk = rng.normal(size=(64, 64))
    Wv = rng.normal(size=(64, 64))
    Wqkv = np.concatenate([Wq, Wk, Wv], axis=-1)

    def run_separate():
        return project_qkv_separate(x, Wq, Wk, Wv)

    def run_fused():
        return project_qkv_fused(x, Wqkv)

    functions = {"separate": run_separate, "fused": run_fused}

    separate_outputs = run_separate()
    fused_outputs = run_fused()
    assert len(separate_outputs) == len(fused_outputs) == 3
    assert all(
        a.shape == b.shape == (128, 64)
        for a, b in zip(separate_outputs, fused_outputs)
    )
    max_error = max(
        float(np.max(np.abs(a - b)))
        for a, b in zip(separate_outputs, fused_outputs)
    )
    assert all(
        np.allclose(a, b, rtol=1e-12, atol=1e-12)
        for a, b in zip(separate_outputs, fused_outputs)
    )

    warmup_calls = 20
    batch_calls = 200
    repeats = 9
    for function in functions.values():
        for _ in range(warmup_calls):
            function()

    samples = {"separate": [], "fused": []}
    for repetition in range(repeats):
        order = ("separate", "fused") if repetition % 2 == 0 else ("fused", "separate")
        for name in order:
            samples[name].append(time_batch(functions[name], batch_calls))

    separate_us = float(np.median(samples["separate"])) / 1000
    fused_us = float(np.median(samples["fused"])) / 1000

    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("随机种子: 0; X:", x.shape, "Wq/Wk/Wv:", Wq.shape, "Wqkv:", Wqkv.shape)
    print("Q/K/V 最大绝对误差:", max_error)
    print("预热: 每种实现", warmup_calls, "次; 重复:", repeats, "组 × 每组", batch_calls, "次")
    print("计时范围: 仅 QKV 投影与切分; 权重拼接和正确性检查在计时外")
    print(f"分开计算中位时间: {separate_us:.3f} 微秒/次")
    print(f"融合计算中位时间: {fused_us:.3f} 微秒/次")
    print(f"本次时间比值（分开/融合）: {separate_us / fused_us:.3f}")
    print("理论 MAC 次数: 两者均为", 3 * x.shape[0] * x.shape[1] ** 2)
    print("PASS: Q、K、V 数值一致；时间仅代表本次运行环境")


if __name__ == "__main__":
    main()
