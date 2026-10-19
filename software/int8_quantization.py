"""INT8 第 1～3 课：转换规则、QKV 存储/误差与完整 Block 对比。"""

import sys

import numpy as np

from transformer_numpy import make_example, transformer_block


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



def check_projection_example():
    """第 2 课：用可手算点积核对量化误差向投影的传播。"""
    x = np.array([[1.0, 2.0]])
    W = np.array([[-1.27, 0.237], [0.504, 1.27]])
    q, scale = quantize_symmetric_int8(W)
    restored = dequantize_int8(q, scale, dtype=W.dtype)
    original_projection = x @ W
    quant_projection = x @ restored
    assert np.allclose(original_projection, [[-0.262, 2.777]], rtol=0, atol=1e-12)
    assert np.allclose(quant_projection, [[-0.270, 2.780]], rtol=0, atol=1e-12)
    assert np.max(np.abs(original_projection - quant_projection)) <= 3 * scale / 2 + 1e-12


def compare_quantization(x, parameters):
    """仅量化三个投影权重，返回存储、逐阶段误差和两路完整输出。"""
    weight_names = ("Wq", "Wk", "Wv")
    original_x = x.copy()
    original_parameters = {name: value.copy() for name, value in parameters.items()}

    # 两路共用同一套前向计算；复制字典后只替换三项。
    float_output, float_trace = transformer_block(x, parameters)
    quant_parameters = parameters.copy()
    integer_weights = {}
    scales = {}
    weight_report = {}

    for name in weight_names:
        W = parameters[name]
        q, scale = quantize_symmetric_int8(W)
        restored = dequantize_int8(q, scale, dtype=W.dtype)
        tolerance = 8 * np.finfo(W.dtype).eps * max(1.0, float(np.max(np.abs(W))))
        weight_error = float(np.max(np.abs(W - restored)))
        assert q.shape == restored.shape == W.shape
        assert q.dtype == np.int8 and restored.dtype == W.dtype
        assert q.min() >= -127 and q.max() <= 127
        assert weight_error <= float(scale) / 2 + tolerance
        integer_weights[name] = q
        scales[name] = scale
        quant_parameters[name] = restored
        weight_report[name] = {
            "scale": float(scale),
            "integer_min": int(q.min()),
            "integer_max": int(q.max()),
            "max_error": weight_error,
            "half_step": float(scale) / 2,
        }

    # 第 2 课：统计明确的数据表示，三个 scale 也作为数组打包。
    scale_data = np.asarray([scales[name] for name in weight_names],
                            dtype=parameters["Wq"].dtype)
    float_bytes = sum(parameters[name].nbytes for name in weight_names)
    int8_bytes = sum(integer_weights[name].nbytes for name in weight_names)
    storage = {
        "float_weights": float_bytes,
        "int8_weights": int8_bytes,
        "scales": scale_data.nbytes,
        "packed": int8_bytes + scale_data.nbytes,
        "dequantized_weights": sum(quant_parameters[name].nbytes for name in weight_names),
    }

    # 第 3 课：反量化数组进入原来的完整 Post-LN Block。
    quant_output, quant_trace = transformer_block(x, quant_parameters)
    names = ("Q", "K", "V", "S", "P", "PV", "attention_output", "H1", "F", "H2")
    errors = {
        name: float(np.max(np.abs(float_trace[name] - quant_trace[name])))
        for name in names
    }
    for trace in (float_trace, quant_trace):
        assert all(np.isfinite(value).all() for value in trace.values())
        for name in ("Q", "K", "V", "PV", "attention_output", "H1", "F", "H2"):
            assert trace[name].shape == x.shape
        assert trace["S"].shape == trace["P"].shape == (x.shape[0], x.shape[0])
        assert np.all(trace["P"] >= 0)
        assert np.allclose(trace["P"].sum(axis=-1), 1.0, rtol=0, atol=1e-12)
        assert np.allclose(trace["H1"].mean(axis=-1), 0.0, rtol=0, atol=1e-12)
        assert np.allclose(trace["H2"].mean(axis=-1), 0.0, rtol=0, atol=1e-12)
    assert float_output.shape == quant_output.shape == x.shape

    # 权重半格界传播到 X@W：每行用 sum(abs(X)) 加权，广播至各输出列。
    for projection, weight in zip(("Q", "K", "V"), weight_names):
        bound = np.sum(np.abs(x), axis=-1, keepdims=True) * float(scales[weight]) / 2
        magnitude = max(1.0, float(np.max(np.abs(float_trace[projection]))),
                        float(np.max(np.abs(quant_trace[projection]))))
        tolerance = 64 * np.finfo(x.dtype).eps * magnitude
        assert np.all(np.abs(float_trace[projection] - quant_trace[projection])
                      <= bound + tolerance)

    # 验证输入与浮点基线未被改写，其他参数在两路完全相同。
    assert np.array_equal(x, original_x)
    for name, value in parameters.items():
        assert np.array_equal(value, original_parameters[name])
        if name not in weight_names:
            assert np.array_equal(quant_parameters[name], value)

    return {
        "weights": weight_report,
        "storage": storage,
        "errors": errors,
        "float_output": float_output,
        "quant_output": quant_output,
        "float_trace": float_trace,
        "quant_trace": quant_trace,
    }

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
    print("PASS: 第 1 课转换规则与最小例子检查")

    check_projection_example()
    x, parameters = make_example()
    report = compare_quantization(x, parameters)
    storage = report["storage"]
    assert storage == {
        "float_weights": 384, "int8_weights": 48, "scales": 24,
        "packed": 72, "dequantized_weights": 384,
    }
    print("第 2、3 课: 随机种子 0; X:", x.shape,
          "Wq/Wk/Wv:", parameters["Wq"].shape, "dtype:", x.dtype)
    for name, values in report["weights"].items():
        print(name, "scale:", values["scale"],
              "整数范围:", (values["integer_min"], values["integer_max"]),
              "权重最大误差:", values["max_error"],
              "半格界:", values["half_step"])
    print("存储字节:", storage)
    print("浮点/INT8数据比:", storage["float_weights"] / storage["int8_weights"])
    print("浮点/含scale量化数据比:", storage["float_weights"] / storage["packed"])
    for name, error in report["errors"].items():
        print(name, "最大绝对误差:", error)
    print("浮点 H2:\n", report["float_output"])
    print("量化权重反量化后 H2:\n", report["quant_output"])
    print("PASS: 存储、权重/投影误差界、概率/归一化、有限值及基线保持检查")
    print("最终 H2 误差如实报告；本实验未规定固定质量阈值，也未测量运行加速")


if __name__ == "__main__":
    main()
