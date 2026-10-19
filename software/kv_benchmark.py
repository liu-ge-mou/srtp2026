"""分别报告 KV 投影计数、缓存数据字节数与整段逐 Token 解码时间。"""

import sys
from time import perf_counter_ns

import numpy as np

from kv_cache import decode_cached
from kv_recompute import decode_recompute
from transformer_numpy import make_example


def cache_capacity_bytes(length, width, dtype):
    """单序列、单层、单 KV 头：K 和 V 各为 (length, width)。"""
    return 2 * length * width * np.dtype(dtype).itemsize


def time_batch(function, calls):
    """返回一次完整序列解码的平均纳秒数，而不是单 Token 时间。"""
    start = perf_counter_ns()
    for _ in range(calls):
        function()
    return (perf_counter_ns() - start) / calls


def compare_case(x, weights):
    """同一输入与权重，先核对正确性和容量，再交替计时。"""
    def run_recompute():
        return decode_recompute(x, *weights)

    def run_cached():
        # 每次函数调用都会重新分配空缓存，不沿用上次调用的 K/V。
        return decode_cached(x, *weights)

    plain, plain_counts = run_recompute()
    cached, cached_counts = run_cached()
    assert plain.shape == cached.shape == x.shape
    assert np.isfinite(plain).all() and np.isfinite(cached).all()
    assert np.allclose(plain, cached, rtol=1e-10, atol=1e-12)

    length, width = x.shape
    # 本例 X 和全部权重均为 float64，因此 K/V 元素类型也为 float64。
    cache_dtype = np.result_type(x, weights[1], weights[2])
    expected_bytes = cache_capacity_bytes(length, width, cache_dtype)
    assert cached_counts["cache_bytes"] == expected_bytes
    assert plain_counts["total"] == width * length * (length + 1)
    assert cached_counts["total"] == 2 * width * length
    assert plain_counts["repeated"] == width * length * (length - 1)
    assert cached_counts["repeated"] == 0
    # 独立的小例子核对容量函数；float64 与 float32 的元素大小不同。
    assert cache_capacity_bytes(3, 4, np.float64) == 192
    assert cache_capacity_bytes(3, 4, np.float32) == 96

    functions = {"recompute": run_recompute, "cached": run_cached}
    warmup_calls, batch_calls, repeats = 10, 20, 9
    for function in functions.values():
        for _ in range(warmup_calls):
            function()

    samples = {name: [] for name in functions}
    for repetition in range(repeats):
        order = ("recompute", "cached") if repetition % 2 == 0 else ("cached", "recompute")
        for name in order:
            samples[name].append(time_batch(functions[name], batch_calls))
    plain_ms = float(np.median(samples["recompute"])) / 1_000_000
    cached_ms = float(np.median(samples["cached"])) / 1_000_000

    print("X:", x.shape, "dtype:", x.dtype, "每元素字节:", np.dtype(cache_dtype).itemsize)
    print("两版输出最大绝对误差:", np.max(np.abs(plain - cached)))
    print("K/V 累计投影元素数（重算/缓存）:",
          plain_counts["total"], cached_counts["total"])
    print("K/V 重复投影元素数（重算/缓存）:",
          plain_counts["repeated"], cached_counts["repeated"])
    print("缓存公式/两数组 nbytes:", expected_bytes, cached_counts["cache_bytes"], "字节")
    print("预热:", warmup_calls, "次; 重复:", repeats, "组 × 每组", batch_calls, "次完整解码")
    print(f"重算/缓存中位时间: {plain_ms:.6f} / {cached_ms:.6f} 毫秒/整段")
    print(f"本次时间比值（重算/缓存）: {plain_ms / cached_ms:.3f}")
    print("重算每组平均毫秒:", [round(v / 1_000_000, 6) for v in samples["recompute"]])
    print("缓存每组平均毫秒:", [round(v / 1_000_000, 6) for v in samples["cached"]])


def main():
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    blas = np.show_config(mode="dicts").get("Build Dependencies", {}).get("blas", {})
    print("NumPy BLAS 构建后端:", blas.get("name", "unknown"))
    print("种子: 0; 计时含整段逐 Token 解码、缓存分配/写入、输出组装和现有计数")
    print("输入/权重生成、正确性检查、容量核算和打印在计时外")
    print("缓存字节只计 K/V 数组数据，不是进程峰值内存；时间不是单 Token 延迟")

    x, parameters = make_example()
    weights = tuple(parameters[name] for name in ("Wq", "Wk", "Wv", "Wo"))
    compare_case(x, weights)

    # 扩大输入观察本例的耗时；此规模是额外实验，并非 KV Cache 原始规定尺寸。
    rng = np.random.default_rng(0)
    x = rng.normal(size=(128, 64))
    weights = tuple(rng.normal(size=(64, 64)) / np.sqrt(64) for _ in range(4))
    compare_case(x, weights)
    print("PASS: 输出一致、容量与投影计数通过；时间比值只描述本次测量")


if __name__ == "__main__":
    main()
