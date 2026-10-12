"""用 NumPy 实现题目要求的单头注意力和 Post-LN Transformer block。"""

import sys

import numpy as np


def softmax(x):
    """沿最后一维归一化；先减最大值，防止 exp 溢出。"""
    shifted = x - np.max(x, axis=-1, keepdims=True)
    exp_scores = np.exp(shifted)
    return exp_scores / np.sum(exp_scores, axis=-1, keepdims=True)


def layer_norm(x, eps=1e-5):
    """对每个 token 的特征做归一化，不包含可学习的缩放和偏移。"""
    mean = np.mean(x, axis=-1, keepdims=True)
    variance = np.mean((x - mean) ** 2, axis=-1, keepdims=True)
    return (x - mean) / np.sqrt(variance + eps)


def self_attention(x, Wq, Wk, Wv, Wo):
    """计算单头注意力，返回输出和便于检查的中间结果。"""
    Q = x @ Wq                     # (3, 4)
    K = x @ Wk                     # (3, 4)
    V = x @ Wv                     # (3, 4)
    S = Q @ K.T / np.sqrt(K.shape[-1])  # (3, 3)
    P = softmax(S)                 # (3, 3)
    PV = P @ V                     # (3, 4)
    output = PV @ Wo               # (3, 4)
    return output, {"Q": Q, "K": K, "V": V, "S": S, "P": P, "PV": PV}


def feed_forward(x, W1, b1, W2, b2):
    """每个 token 独立执行 (4 -> 8 -> 4) 的两层变换。"""
    hidden = np.maximum(x @ W1 + b1, 0.0)  # ReLU，形状 (3, 8)
    return hidden @ W2 + b2                 # 形状 (3, 4)


def transformer_block(x, parameters):
    """按题目顺序执行两次残差连接和 Post-LN。"""
    attention_output, values = self_attention(
        x,
        parameters["Wq"],
        parameters["Wk"],
        parameters["Wv"],
        parameters["Wo"],
    )
    H1_input = x + attention_output
    H1 = layer_norm(H1_input)
    F = feed_forward(
        H1,
        parameters["W1"],
        parameters["b1"],
        parameters["W2"],
        parameters["b2"],
    )
    H2_input = H1 + F
    H2 = layer_norm(H2_input)
    values.update({
        "attention_output": attention_output,
        "H1_input": H1_input,
        "H1": H1,
        "F": F,
        "H2_input": H2_input,
        "H2": H2,
    })
    return H2, values


def make_example():
    """固定种子，生成三个 token 和题目指定形状的权重。"""
    rng = np.random.default_rng(0)
    x = rng.normal(size=(3, 4))
    parameters = {
        "Wq": rng.normal(size=(4, 4)),
        "Wk": rng.normal(size=(4, 4)),
        "Wv": rng.normal(size=(4, 4)),
        "Wo": rng.normal(size=(4, 4)),
        "W1": rng.normal(size=(4, 8)),
        "b1": rng.normal(size=(8,)),
        "W2": rng.normal(size=(8, 4)),
        "b2": rng.normal(size=(4,)),
    }
    return x, parameters


def check_example(x, parameters, output, values):
    """检查形状、概率、归一化、数值稳定性和输入扰动。"""
    shapes = {
        "Q": (3, 4),
        "K": (3, 4),
        "V": (3, 4),
        "S": (3, 3),
        "P": (3, 3),
        "PV": (3, 4),
        "attention_output": (3, 4),
        "H1_input": (3, 4),
        "H1": (3, 4),
        "F": (3, 4),
        "H2_input": (3, 4),
        "H2": (3, 4),
    }
    for name, expected in shapes.items():
        assert values[name].shape == expected, (name, values[name].shape)
    assert output.shape == x.shape == (3, 4)
    assert np.all(values["P"] >= 0)
    assert np.allclose(values["P"].sum(axis=1), 1.0, atol=1e-12)
    assert np.allclose(values["H1"].mean(axis=1), 0.0, atol=1e-12)
    assert np.allclose(values["H2"].mean(axis=1), 0.0, atol=1e-12)
    assert all(np.isfinite(value).all() for value in values.values())

    # 用前一课手算的 2×2 例子独立核对 FFN。
    small_x = np.array([[1.0, -2.0], [0.0, 3.0]])
    small_W1 = np.array([[1.0, -1.0], [2.0, 1.0]])
    small_b1 = np.array([0.0, 1.0])
    small_W2 = np.array([[1.0, 2.0], [-1.0, 1.0]])
    small_b2 = np.array([1.0, 0.0])
    expected_ffn = np.array([[1.0, 0.0], [3.0, 16.0]])
    assert np.array_equal(
        feed_forward(small_x, small_W1, small_b1, small_W2, small_b2),
        expected_ffn,
    )
    # 正负大数不会让 softmax 和整块输出产生 inf/nan。
    extreme_scores = np.array([[1000.0, 1001.0, -1000.0]])
    assert np.isfinite(softmax(extreme_scores)).all()
    large_output, large_values = transformer_block(x * 1000.0, parameters)
    assert np.isfinite(large_output).all()
    assert np.isfinite(large_values["P"]).all()

    # 只修改第一个 token；同一组权重下，注意力和最终输出应改变。
    changed_x = x.copy()
    changed_x[0, 0] += 0.25
    changed_output, changed_values = transformer_block(changed_x, parameters)
    assert not np.allclose(changed_values["P"], values["P"])
    assert not np.allclose(changed_output, output)


def main():
    x, parameters = make_example()
    output, values = transformer_block(x, parameters)
    check_example(x, parameters, output, values)

    np.set_printoptions(precision=4, suppress=True)
    print("Python:", sys.version.split()[0], "NumPy:", np.__version__)
    print("随机种子: 0")
    print("X:", x.shape)
    for name in ("Q", "K", "V", "S", "P", "PV", "attention_output", "H1", "F", "H2"):
        print(name + ":", values[name].shape)
    print("注意力矩阵 P:\n", values["P"])
    print("P 的行和:", values["P"].sum(axis=1))
    print("H1 的行均值:", values["H1"].mean(axis=1))
    print("H2 的行均值:", values["H2"].mean(axis=1))
    print("最终输出 H2:\n", output)
    print("PASS: 形状、行和、归一化、有限值和输入扰动检查")


if __name__ == "__main__":
    main()