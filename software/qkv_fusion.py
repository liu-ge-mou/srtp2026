"""验证 QKV 权重拼接后与三次独立投影的数值一致性。"""

import sys

import numpy as np

from transformer_numpy import feed_forward, layer_norm, make_example, softmax, transformer_block


def project_qkv_fused(x, Wqkv):
    """Wqkv 已预先拼接；这里只进行一次矩阵乘法和三段切分。"""
    qkv = x @ Wqkv
    return np.split(qkv, 3, axis=-1)


def attention_from_qkv(Q, K, V, Wo):
    """从已得到的 Q、K、V 计算单头注意力输出。"""
    scores = Q @ K.T / np.sqrt(K.shape[-1])
    weights = softmax(scores)
    return (weights @ V) @ Wo


def block_from_attention(x, attention_output, parameters):
    """沿用同一组 FFN 权重，比较融合后的完整 Post-LN 输出。"""
    H1 = layer_norm(x + attention_output)
    F = feed_forward(
        H1,
        parameters["W1"],
        parameters["b1"],
        parameters["W2"],
        parameters["b2"],
    )
    return layer_norm(H1 + F)


def main():
    x, parameters = make_example()  # 固定随机种子 0；X 形状 (3, 4)
    Wq = parameters["Wq"]
    Wk = parameters["Wk"]
    Wv = parameters["Wv"]
    Wo = parameters["Wo"]

    Q_separate = x @ Wq
    K_separate = x @ Wk
    V_separate = x @ Wv

    # 在投影之前拼接一次；后续计时时也应放在计时范围之外。
    Wqkv = np.concatenate([Wq, Wk, Wv], axis=-1)  # (4, 12)
    Q_fused, K_fused, V_fused = project_qkv_fused(x, Wqkv)

    assert Wqkv.shape == (4, 12)
    assert Q_fused.shape == K_fused.shape == V_fused.shape == (3, 4)
    for separate, fused in (
        (Q_separate, Q_fused),
        (K_separate, K_fused),
        (V_separate, V_fused),
    ):
        assert np.allclose(separate, fused, rtol=1e-12, atol=1e-12)

    attention_separate = attention_from_qkv(
        Q_separate, K_separate, V_separate, Wo
    )
    attention_fused = attention_from_qkv(Q_fused, K_fused, V_fused, Wo)
    assert np.allclose(
        attention_separate, attention_fused, rtol=1e-12, atol=1e-12
    )

    block_separate, _ = transformer_block(x, parameters)
    block_fused = block_from_attention(x, attention_fused, parameters)
    assert np.allclose(block_separate, block_fused, rtol=1e-12, atol=1e-12)

    max_qkv_error = max(
        np.max(np.abs(separate - fused))
        for separate, fused in (
            (Q_separate, Q_fused),
            (K_separate, K_fused),
            (V_separate, V_fused),
        )
    )
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("随机种子: 0")
    print("X:", x.shape, "Wqkv:", Wqkv.shape)
    print("QKV 最大绝对误差:", max_qkv_error)
    print(
        "注意力输出最大绝对误差:",
        np.max(np.abs(attention_separate - attention_fused)),
    )
    print(
        "Block 输出最大绝对误差:",
        np.max(np.abs(block_separate - block_fused)),
    )
    print("QKV 投影的矩阵乘法调用次数: 分开 3 次，融合 1 次")
    print("QKV 投影的理论 MAC 次数: 两者均为", 3 * x.shape[0] * x.shape[1] ** 2)
    print("PASS: Q、K、V、注意力输出和 Block 输出一致")


if __name__ == "__main__":
    main()