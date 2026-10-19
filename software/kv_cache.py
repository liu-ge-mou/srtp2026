"""简单 KV Cache：每步只计算新 Token 的 K/V，并复用先前结果。"""

import sys

import numpy as np

from causal_attention import causal_self_attention
from kv_recompute import decode_recompute
from transformer_numpy import make_example, softmax


def decode_cached(x, Wq, Wk, Wv, Wo):
    """返回逐步输出与每步新计算的 K/V 投影元素数。"""
    if x.ndim != 2 or x.shape[0] == 0:
        raise ValueError("x 必须是包含至少一个 Token 的二维数组")
    length, width = x.shape
    K_cache = np.empty((length, width), dtype=np.result_type(x, Wk))
    V_cache = np.empty((length, width), dtype=np.result_type(x, Wv))
    outputs = []
    kv_elements_each_step = []

    for end in range(1, length + 1):
        current = x[end - 1:end]            # (1, d)：只取新 Token
        q = current @ Wq                    # (1, d)
        k_new = current @ Wk                # (1, d)：只算本步
        v_new = current @ Wv                # (1, d)：只算本步
        K_cache[end - 1:end] = k_new
        V_cache[end - 1:end] = v_new
        K = K_cache[:end]                   # (end, d)：已写入的历史与当前
        V = V_cache[:end]
        scores = q @ K.T / np.sqrt(K.shape[-1])  # (1, end)
        weights = softmax(scores)           # (1, end)
        outputs.append((weights @ V) @ Wo)  # (1, d)
        kv_elements_each_step.append(k_new.size + v_new.size)

    all_outputs = np.vstack(outputs)        # (length, d)
    counts = {
        "each_step": kv_elements_each_step,
        "total": sum(kv_elements_each_step),
        "repeated": 0,
        "cache_bytes": K_cache.nbytes + V_cache.nbytes,
    }
    return all_outputs, counts


def check_example(x, parameters, output, counts):
    args = (
        x, parameters["Wq"], parameters["Wk"],
        parameters["Wv"], parameters["Wo"],
    )
    recomputed, recompute_counts = decode_recompute(*args)
    full_output, _ = causal_self_attention(*args)
    length, width = x.shape

    assert output.shape == recomputed.shape == full_output.shape == x.shape
    assert np.isfinite(output).all()
    assert np.allclose(output, recomputed, rtol=1e-12, atol=1e-12)
    assert np.allclose(output, full_output, rtol=1e-12, atol=1e-12)
    assert counts["each_step"] == [2 * width] * length
    assert counts["total"] == 2 * length * width
    assert counts["repeated"] == 0
    assert recompute_counts["repeated"] == width * length * (length - 1)

    # 二维单位权重例子直接核对第 2 步，避免只依赖另一实现。
    toy_x = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]])
    identity = np.eye(2)
    toy_output, toy_counts = decode_cached(
        toy_x, identity, identity, identity, identity,
    )
    assert np.array_equal(toy_output[0], [1.0, 0.0])
    assert np.allclose(toy_output[1], [0.33023845, 0.66976155], atol=1e-7)
    assert toy_counts["each_step"] == [4, 4, 4]
    assert toy_counts["total"] == 12


def main():
    x, parameters = make_example()
    args = (
        x, parameters["Wq"], parameters["Wk"],
        parameters["Wv"], parameters["Wo"],
    )
    output, counts = decode_cached(*args)
    check_example(x, parameters, output, counts)
    recomputed, recompute_counts = decode_recompute(*args)

    np.set_printoptions(precision=4, suppress=True)
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("X:", x.shape, "逐步输出:", output.shape)
    print("K/V 投影元素数: 重算", recompute_counts["each_step"],
          "缓存", counts["each_step"])
    print("累计 K/V 元素数: 重算", recompute_counts["total"],
          "缓存", counts["total"])
    print("重复 K/V 元素数: 重算", recompute_counts["repeated"],
          "缓存", counts["repeated"])
    print("逐步输出最大绝对误差:", np.max(np.abs(output - recomputed)))
    print("最后一个 Token 最大绝对误差:",
          np.max(np.abs(output[-1] - recomputed[-1])))
    print("缓存版逐步输出:\n", output)
    print("PASS: 缓存版每步输出匹配重算和整段因果注意力，K/V 只投影新 Token")


if __name__ == "__main__":
    main()
