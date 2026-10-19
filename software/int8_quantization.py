"""INT8 第 1 课：按矩阵对称量化、反量化及最小数值检查。"""

import sys

import numpy as np


def quantize_symmetric_int8(W):
    """浮点二维矩阵 -> 同形状 int8 数组 q，以及原浮点类型的正 scale。"""
    W = np.asarray(W)
    if W.ndim != 2 or W.size == 0 or not np.issubdtype(W.dtype, np.floating):
        raise ValueError("W 必须是非空的浮点二维矩阵")
    if not np.isfinite(W).all():
        raise ValueError("W 必须全部为有限值")

    max_abs = np.max(np.abs(W))
    # 全零矩阵固定用 s=1，量化和反量化均为零，避免除零。
    scale = W.dtype.type(1.0 if max_abs == 0 else max_abs / 127.0)
    if not np.isfinite(scale) or scale <= 0:
        raise ValueError("当前浮点类型无法表示有效的正 scale")

    scaled = W / scale
    rounded = np.rint(scaled)
    q = np.clip(rounded, -127, 127).astype(np.int8)
    return q, scale


def dequantize_int8(q, scale, dtype=np.float64):
    """int8 数组 -> 指定浮点类型的近似权重 W_hat。"""
    q = np.asarray(q)
    dtype = np.dtype(dtype)
    if q.dtype != np.int8 or not np.issubdtype(dtype, np.floating):
        raise ValueError("q 必须为 int8，输出 dtype 必须为浮点类型")
    if not np.isscalar(scale) or not np.isfinite(scale) or scale <= 0:
        raise ValueError("scale 必须为正的有限标量")
    return q.astype(dtype) * dtype.type(scale)


def check_example(W, q, scale, restored):
    """用手算结果、量化误差界、零矩阵和舍入中点核对转换规则。"""
    expected_q = np.array([[-127, 24], [50, 127]], dtype=np.int8)
    expected_restored = np.array([[-1.27, 0.24], [0.50, 1.27]])
    assert q.shape == restored.shape == W.shape == (2, 2)
    assert q.dtype == np.int8 and restored.dtype == W.dtype
    assert np.isfinite(restored).all()
    assert q.min() >= -127 and q.max() <= 127
    assert np.isclose(scale, 0.01, rtol=0, atol=1e-15)
    assert np.array_equal(q, expected_q)
    assert np.allclose(restored, expected_restored, rtol=0, atol=1e-15)
    assert q[0, 0] == -127 and q[1, 1] == 127

    tolerance = 8 * np.finfo(W.dtype).eps * max(1.0, float(np.max(np.abs(W))))
    assert np.max(np.abs(W - restored)) <= float(scale) / 2 + tolerance

    zero = np.zeros((2, 2), dtype=np.float64)
    zero_q, zero_scale = quantize_symmetric_int8(zero)
    assert zero_scale == 1.0
    assert np.array_equal(zero_q, np.zeros((2, 2), dtype=np.int8))
    assert np.array_equal(dequantize_int8(zero_q, zero_scale), zero)

    # scale=1，使 .5 中点可以精确表示；np.rint 采用最近偶数规则。
    ties = np.array([[-127.0, -2.5, -1.5, 0.0, 1.5, 2.5, 127.0]])
    ties_q, ties_scale = quantize_symmetric_int8(ties)
    assert ties_scale == 1.0
    assert np.array_equal(ties_q, np.array([[-127, -2, -2, 0, 2, 2, 127]], dtype=np.int8))


def main():
    W = np.array([[-1.27, 0.237], [0.504, 1.27]], dtype=np.float64)
    original = W.copy()
    q, scale = quantize_symmetric_int8(W)
    restored = dequantize_int8(q, scale, dtype=W.dtype)
    check_example(W, q, scale, restored)
    assert np.array_equal(W, original)

    np.set_printoptions(precision=6, suppress=True)
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("固定手算矩阵 W:\n", W)
    print("scale:", scale)
    print("W/scale:\n", W / scale)
    print("q:", q.dtype, "\n", q)
    print("反量化 W_hat:", restored.dtype, "\n", restored)
    print("绝对误差:\n", np.abs(W - restored))
    print("最大绝对误差:", float(np.max(np.abs(W - restored))))
    print("理论半格误差界 scale/2:", float(scale) / 2)
    print("PASS: 手算、形状、端点、全零、最近偶数舍入、半格误差界和输入保持检查")


if __name__ == "__main__":
    main()
