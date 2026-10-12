"""逐 Token 解码基线：每一步重算当前及全部历史 Token 的 K、V。"""

import sys

import numpy as np

from causal_attention import causal_self_attention
from transformer_numpy import make_example, softmax


def decode_recompute(x, Wq, Wk, Wv, Wo):
    """返回每步新 Token 的输出、每步 K/V 元素数和累计计数。"""
    if x.ndim != 2 or x.shape[0] == 0:
        raise ValueError("x 必须是包含至少一个 Token 的二维数组")
    length, width = x.shape
    outputs = []
    kv_elements_each_step = []

    for end in range(1, length + 1):
        current = x[end - 1:end]             # (1, d)：本步的新 Token
        history = x[:end]                    # (end, d)：含当前 Token 的前缀
        q = current @ Wq                     # (1, d)
        K = history @ Wk                     # (end, d)，每步重新计算
        V = history @ Wv                     # (end, d)，每步重新计算
        scores = q @ K.T / np.sqrt(K.shape[-1])  # (1, end)
        weights = softmax(scores)            # (1, end)，前缀内没有未来
        output = (weights @ V) @ Wo           # (1, d)
        outputs.append(output)
        kv_elements_each_step.append(K.size + V.size)

    all_outputs = np.vstack(outputs)         # (length, d)
    total = sum(kv_elements_each_step)
    unique = 2 * length * width              # 每个 Token 的 K/V 各算一次
    counts = {
        "each_step": kv_elements_each_step,
        "total": total,
        "unique": unique,
        "repeated": total - unique,
    }
    return all_outputs, counts


def check_example(x, parameters, output, counts):
    full_output, _ = causal_self_attention(
        x, parameters["Wq"], parameters["Wk"],
        parameters["Wv"], parameters["Wo"],
    )
    length, width = x.shape
    assert output.shape == full_output.shape == x.shape
    assert np.allclose(output, full_output, rtol=1e-12, atol=1e-12)
    assert np.isfinite(output).all()
    assert counts["each_step"] == [2 * width * end for end in range(1, length + 1)]
    assert counts["total"] == 2 * width * length * (length + 1) // 2
    assert counts["unique"] == 2 * width * length
    assert counts["repeated"] == 2 * width * length * (length - 1) // 2

    # 使用上一课的三 Token、二维单位权重例子核对前两步。
    toy_x = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]])
    identity = np.eye(2)
    toy_output, toy_counts = decode_recompute(
        toy_x, identity, identity, identity, identity,
    )
    assert np.array_equal(toy_output[0], [1.0, 0.0])
    assert np.allclose(toy_output[1], [0.33023845, 0.66976155], atol=1e-7)
    assert toy_counts["each_step"] == [4, 8, 12]
    assert toy_counts["total"] == 24
    assert toy_counts["repeated"] == 12


def main():
    x, parameters = make_example()
    output, counts = decode_recompute(
        x, parameters["Wq"], parameters["Wk"],
        parameters["Wv"], parameters["Wo"],
    )
    check_example(x, parameters, output, counts)
    full_output, _ = causal_self_attention(
        x, parameters["Wq"], parameters["Wk"],
        parameters["Wv"], parameters["Wo"],
    )

    np.set_printoptions(precision=4, suppress=True)
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("X:", x.shape, "逐步输出:", output.shape)
    print("每步 K/V 投影元素数:", counts["each_step"])
    print("累计/只算一次/重复元素数:",
          counts["total"], counts["unique"], counts["repeated"])
    print("与整段因果注意力的最大绝对误差:",
          np.max(np.abs(output - full_output)))
    print("逐步输出:\n", output)
    print("PASS: 逐步输出与整段因果注意力一致，K/V 重算计数符合公式")


if __name__ == "__main__":
    main()
