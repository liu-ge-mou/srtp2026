# NumPy Transformer 基础实现

本目录对应任务清单的“注意力计算”和“Transformer block”。当前已实现单头注意力、Post-LN 前向计算和 QKV 融合一致性检查；计时、因果掩码和 KV Cache 尚未实现。

## 运行

先安装 Python 3 和 NumPy。在仓库根目录执行：

    python -m pip install numpy
    $env:PYTHONIOENCODING = "utf-8"
    python software/transformer_numpy.py
    python software/qkv_fusion.py

已在 Python 3.14.6、NumPy 2.4.6 下运行。程序固定随机种子 0，打印各张量形状、注意力矩阵、行和与最终输出，并在检查失败时抛出 AssertionError。正常结束时打印 PASS。

## 文件中的计算顺序

1. X(3,4) 与四个 4×4 权重生成 Q、K、V、S(3,3)、P(3,3) 和注意力输出(3,4)。
2. S[i,j] 是第 i 个 token 的查询与第 j 个 token 的键的匹配分数；P[i,j] 是聚合第 j 个 token 的值向量时所用的权重。P 的每行和为 1。
3. H1 = LayerNorm(X + Attention(X))。
4. FFN 将 H1 从 (3,4) 变到 (3,8)，经 ReLU 后变回 (3,4)。
5. H2 = LayerNorm(H1 + FFN(H1))。

check_example 检查形状、P 的行和、LayerNorm 行均值、有限值，以及修改第一个 token 后的输出变化。代码和运行通过只代表此示例已验证，不代表学习者独立完成手算或编程。

## QKV 融合

qkv_fusion.py 对应原始实验要求“题目二 → 4. 基础优化：QKV 融合”的第 1、2 项。Wq、Wk、Wv 各为 (4,4)，沿列拼接得到 Wqkv(4,12)。X(3,4) 乘一次 Wqkv 后得到 (3,12)，沿最后一维切成三个 (3,4)。

脚本比较 Q、K、V、注意力输出和完整 Block 输出。当前输入的最大绝对误差均为 0.0。QKV 投影的矩阵乘法调用次数从 3 次变为 1 次；理论 MAC 次数仍为 144。权重拼接发生在投影之前。这里没有计时，也没有证实实际运行加速；性能测量是任务清单的下一项。

### 可手算的拼接例子

取 X = [[1, 2]]，三个 2×2 权重分别为 Wq = [[1,0],[0,1]]、Wk = [[0,1],[1,0]]、Wv = [[2,0],[0,3]]。分开计算得到 Q = [[1,2]]、K = [[2,1]]、V = [[2,6]]。

按列拼接后 Wqkv = [[1,0,0,1,2,0],[0,1,1,0,0,3]]，所以 X @ Wqkv = [[1,2,2,1,2,6]]。按每 2 列切分，恰好得到相同的 Q、K、V。一般形式为 X @ [Wq | Wk | Wv] = [X @ Wq | X @ Wk | X @ Wv]；融合只把三次投影矩阵乘法调用合为一次，乘加项数不变。

### 这份代码的编写顺序

1. 先把原始要求第 4 节第 1 项拆成五个可检查的结果：Q、K、V、注意力输出和完整 Block 输出。前两种实现必须使用相同的 X 与权重，否则不能比较。
2. 在 qkv_fusion.py 的 main 中先写分开计算 Q_separate、K_separate、V_separate，作为基线。make_example 复用基础脚本的固定种子和权重。
3. 用 np.concatenate([Wq, Wk, Wv], axis=-1) 沿列拼接。Wqkv 在调用 project_qkv_fused 前生成；该函数只执行 x @ Wqkv 和按最后一维三等分。这样后续做性能实验时，能够把拼接放在计时区间之外。
4. 先逐一比较 Q、K、V，再用同一 Wo 比较注意力输出，最后用同一 FFN 权重比较 Post-LN Block 输出。np.allclose 使用 rtol=1e-12、atol=1e-12；打印最大绝对误差，便于定位差异。
5. 最后写计算量说明。对 X(N,d) 和三个 (d,d) 权重，分开与融合的投影都需要 3Nd² 次理论 MAC；只是 NumPy 矩阵乘法调用从 3 次变为 1 次。这里的运行结果不能代替计时结论。