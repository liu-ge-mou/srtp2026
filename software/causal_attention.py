"""单层因果自注意力：先遮住未来分数，再按行归一化。"""

import sys

import numpy as np

from transformer_numpy import make_example, softmax


def causal_self_attention(x, Wq, Wk, Wv, Wo):
    """返回各位置的输出，以及检查掩码所需的中间矩阵。"""
    Q = x @ Wq
    K = x @ Wk
    V = x @ Wv
    scores = Q @ K.T / np.sqrt(K.shape[-1])
    length = x.shape[0]
    future = np.triu(np.ones((length, length), dtype=bool), k=1)
    masked_scores = np.where(future, -np.inf, scores)
    weights = softmax(masked_scores)
    output = (weights @ V) @ Wo
    return output, {
        "Q": Q, "K": K, "V": V, "scores": scores,
        "future": future, "masked_scores": masked_scores, "weights": weights,
    }


def check_example(x, parameters, output, values):
    length, width = x.shape
    assert output.shape == (length, width)
    assert values["scores"].shape == (length, length)
    assert values["weights"].shape == (length, length)
    assert np.all(values["weights"][values["future"]] == 0.0)
    assert np.all(values["weights"] >= 0)
    assert np.allclose(values["weights"].sum(axis=1), 1.0, atol=1e-12)
    assert np.isfinite(values["weights"]).all()
    assert np.isfinite(output).all()

    # 前缀输入和完整输入在同一位置的因果输出应一致。
    for end in range(1, length + 1):
        prefix_output, _ = causal_self_attention(
            x[:end], parameters["Wq"], parameters["Wk"],
            parameters["Wv"], parameters["Wo"],
        )
        assert np.allclose(prefix_output, output[:end], rtol=1e-12, atol=1e-12)

    # 直接改动最后一个 token，前面位置的输出不能变化。
    changed = x.copy()
    changed[-1, 0] += 10.0
    changed_output, _ = causal_self_attention(
        changed, parameters["Wq"], parameters["Wk"],
        parameters["Wv"], parameters["Wo"],
    )
    assert np.allclose(changed_output[:-1], output[:-1], rtol=1e-12, atol=1e-12)


def main():
    x, parameters = make_example()
    output, values = causal_self_attention(
        x, parameters["Wq"], parameters["Wk"], parameters["Wv"], parameters["Wo"],
    )
    check_example(x, parameters, output, values)

    # 2 维单位权重便于手算；第一行只能看自己。
    toy_x = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]])
    identity = np.eye(2)
    toy_output, toy = causal_self_attention(
        toy_x, identity, identity, identity, identity,
    )
    assert np.array_equal(toy["weights"][0], [1.0, 0.0, 0.0])
    assert np.allclose(toy["weights"][1], [0.33023845, 0.66976155, 0.0], atol=1e-7)
    assert np.array_equal(toy_output[0], [1.0, 0.0])

    np.set_printoptions(precision=4, suppress=True)
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("X:", x.shape, "scores:", values["scores"].shape, "output:", output.shape)
    print("未来位置掩码 (True 表示禁止):\n", values["future"])
    print("因果注意力权重:\n", values["weights"])
    print("玩具例子权重:\n", toy["weights"])
    print("PASS: 未来位置权重为零、每行和为一、前缀输出一致、未来扰动不影响过去")


if __name__ == "__main__":
    main()
