# 脉动阵列硬件与 Transformer 软件

## 说明

包含两个相互独立的题目：

- **题目一为硬件题。** 提供两个平行方向，选择其中一个完成
- **题目二为软件题。** 使用 Python 和 NumPy 完成 Transformer 基础实现及一个小型部署实验，不涉及 FPGA 电路设计。

两个题目均以理解原理、完成实现和验证结果为主。实验中固定随机种子，并记录必要的软件版本、输入和输出，以便复现结果。

### 实验工具

| 用途 | 工具 | 使用说明 |
|---|---|---|
| 硬件方向 A、B | Xilinx Vivado | 编写 Verilog/SystemVerilog，使用 Vivado Simulator（XSim）完成行为仿真，并使用综合功能检查资源和警告 |
| 硬件方向 B 的参考计算 | MATLAB | 编写简单的 `6×6`—`5×5` 互相关黄金模型，与 RTL 输出比较 |
| Transformer 软件题 | Python 3、NumPy | 完成 Transformer、QKV 融合、KV Cache 或 INT8 小实验；可选用 Matplotlib 绘图 |

已有 `maidong` 工程由 **Vivado 2018.2** 创建，目标器件为 **`xc7a35tcpg236-1`**。建议优先使用 Vivado 2018.2；也可以使用能够兼容该器件的较新版本。若 `.xpr` 因版本或旧路径无法正常打开，应新建 RTL Project，再通过 **Add Sources** 加入配套 Verilog 文件，不直接修改旧机器保存的绝对路径。

硬件题统一使用 Vivado，最低工具流程为：

1. 新建或打开 RTL 工程；
2. 加入 Design Sources 和 Simulation Sources，并设置顶层模块；
3. 运行 **Run Behavioral Simulation**，查看波形并完成结果检查；
4. 运行 **Run Synthesis**，确认没有由本次设计或修改引入的语法错误、位宽错误和锁存器警告；
5. 保存关键波形和 Utilization Summary。无需执行上板、引脚约束和 Generate Bitstream。

题目二不使用 Vivado。基础实现只需 Python 与 NumPy，也不需要安装 PyTorch、TensorFlow 或大模型推理框架。

### 题目一的两个硬件方向

| 方向 | 主要内容 | 难度控制 |
|---|---|---|
| 方向 A：自主设计 | 从零设计一个简单的 `2×2` 脉动阵列 | 只完成小矩阵、基本控制和仿真 |
| 方向 B：已有工程研究 | 阅读并验证配套工程中的四路类脉动卷积电路 | 以理解、测试和一处小修改为主 |

---

## 题目一：脉动阵列硬件设计与研究

### 方向 A：自主设计 `2×2` 脉动阵列

#### 1. 已知条件

使用一个 `2×2` 脉动阵列计算：

$$
C=A\times B
$$

其中：

$$
A=
\begin{bmatrix}
1&2\\
3&4
\end{bmatrix},
\qquad
B=
\begin{bmatrix}
5&6\\
7&8
\end{bmatrix}
$$

矩阵 $A$ 从阵列左侧输入并向右传递，矩阵 $B$ 从阵列上方输入并向下传递。每个处理单元（PE）保存自己的部分和，采用输出驻留（Output Stationary）数据流。

每个 PE 包含：

- 一个乘法器；
- 一个累加寄存器；
- 横向传递 $a$ 的寄存器；
- 纵向传递 $b$ 的寄存器；
- 输入有效信号。

有效数据到达时，PE 执行：

$$
acc\leftarrow acc+a\times b
$$

本方向只使用非负小整数。数据可采用 8 bit 无符号数，累加结果采用 16 bit 无符号数。

#### 2. 结构与时序

1. 画出 `2×2` 脉动阵列结构，标出四个 PE、数据传递方向和四个结果的位置。
2. 说明为什么不同行和不同列的数据需要错开周期输入。
3. 设计 $A$、$B$ 的输入顺序，并填写周期表。每个单元格记录有效输入、乘积和更新后的累加值。

| 时钟周期 | PE(0,0) | PE(0,1) | PE(1,0) | PE(1,1) | 完成的输出 |
|---:|---|---|---|---|---|
| 1 |  |  |  |  |  |
| 2 |  |  |  |  |  |
| 3 |  |  |  |  |  |
| 4 |  |  |  |  |  |

4. 标出 $C_{00}$、$C_{01}$、$C_{10}$、$C_{11}$ 的完成周期，并用普通矩阵乘法复核最终结果。

#### 3. RTL 实现

在 Vivado 中新建 RTL Project，使用 Verilog 或 SystemVerilog 实现：

```verilog
module pe (...);
    // 数据寄存、传递和乘累加
endmodule

module systolic_array_2x2 (...);
    // 四个 PE 的连接、输入错拍和结果控制
endmodule
```

电路要求：

- 采用同步、高电平有效复位；
- 只有 $a$、$b$ 同时有效时才更新累加器；
- 无效周期保持累加结果，同时继续正确传递有效状态；
- 给出表示计算完成的 `done` 或 `out_valid` 信号；
- 一次计算结束后能够重新开始下一次计算。

#### 4. Testbench 验证

Testbench 完成以下测试：

1. 题目给定的 $A$、$B$；
2. 一组自行设置的小整数矩阵；
3. 复位后连续执行两次矩阵乘法。

仿真波形中应能看到输入错拍、PE 间传递、累加变化和结果有效信号。Testbench 可直接写出期望结果，并在不一致时打印 `FAIL`。

完成行为仿真后运行 **Run Synthesis**，记录 `systolic_array_2x2` 的 LUT、FF 和 DSP 使用量，并检查是否出现位宽不一致或锁存器推断警告。不要求实现布局布线或生成比特流。

#### 5. 简单优化：零值跳过

将输入矩阵改为：

$$
A_s=
\begin{bmatrix}
1&0\\
3&4
\end{bmatrix}
$$

当有效输入中的 $a=0$ 或 $b=0$ 时，禁止本周期乘累加，但仍正常传递 $a$、$b$ 和 `valid`。

比较优化前后的结果和实际执行的 MAC 次数，并简要说明：

- 为什么跳过乘法不一定减少固定调度阵列的总周期；
- 该修改更可能影响动态功耗、芯片面积还是关键路径。

#### 6. 本方向结果记录

记录阵列结构图、周期表、RTL 代码、关键波形、自动检查结果及零值跳过前后的 MAC 次数。

---

### 方向 B：基于已有脉动卷积电路进行研究

#### 1. 工程内容

配套 LeNet 工程中的相关文件为：

| 文件 | 作用 |
|---|---|
| `maidong/maidong.srcs/sources_1/new/systolic_conv_network.v` | 从 `6×6` 输入中拆分四个 `5×5` 窗口 |
| `maidong/maidong.srcs/sources_1/new/systolic_array_conv.v` | 使用四条乘累加通路计算四个输出 |
| `maidong/maidong.srcs/sim_1/new/test_systolic_conv_network.v` | 提供时钟、输入图像、卷积核和偏置 |
| `lenet5_matlab/Convforward_npu.m` | MATLAB 卷积计算参考 |
| `lenet5_matlab/tmu.m` | MATLAB 向量乘加与跳过行为参考 |

已有工程仅作为待分析的参考实现，不假定其中所有接口、时序和数值处理都正确。

原 `.xpr` 还依赖 `add.v`、`multi.v`、`mul.v` 和 `mul7_4.v`。如果 Vivado 报告源文件路径失效，可从配套工程的 `lenet5/src/design/lenet/` 目录重新加入这些文件，并把 `test_systolic_conv_network.v` 设置为仿真顶层。

#### 2. 计算任务

设输入 $I\in\mathbb{Z}^{6\times6}$、卷积核 $K\in\mathbb{Z}^{5\times5}$、步长为 1、无填充，输出 $Y\in\mathbb{Z}^{2\times2}$：

$$
Y_{r,c}=b+\sum_{i=0}^{4}\sum_{j=0}^{4}I_{r+i,c+j}K_{i,j},
\qquad r,c\in\{0,1\}
$$

采用 CNN 中常用的互相关形式，不翻转卷积核。

#### 3. 阅读与原理分析

1. 画出“窗口拆分—四路 MAC—加入偏置—输出结果”的结构图。
2. 说明 `6×6` 输入为什么得到四个 `5×5` 窗口。
3. 根据计数器的取值，说明四条通路分别从哪个周期开始、每条通路执行多少次有效乘累加、结果在哪个阶段输出。
4. 判断该设计是严格的二维脉动阵列，还是由集中式计数器调度的四路类脉动 MAC，并说明判断依据。
5. 比较 MATLAB 中沿输入通道组织的 16 路向量乘加与 RTL 中沿四个空间窗口组织的并行计算。

#### 4. MATLAB 参考与 RTL 验证

编写一个简短的 MATLAB 函数，用显式循环计算上述 `6×6`—`5×5` 互相关，作为黄金结果。暂不加入随机跳过或近似乘法。

在已有 Testbench 基础上完成：

1. 复现“输入为 1 到 36、卷积核全 1、偏置为 10”的测试；
2. 增加一个非对称卷积核，避免全 1 卷积核掩盖输入顺序或核方向错误；
3. 将四个 RTL 输出与 MATLAB 结果自动比较，并打印 `PASS/FAIL`；
4. 观察 `counter`、四路乘法输入、累加结果和 `covResVld` 的关键波形。

上述验证使用 Vivado 的 **Run Behavioral Simulation** 完成。修改 RTL 后再运行一次 **Run Synthesis**，对比修改前后的综合警告；资源变化只需作简单记录。

#### 5. 本方向结果记录

记录工程结构图、四路调度说明、MATLAB 参考函数、关键波形、自动比对结果、发现的问题及一处修改前后的现象。

---

## 题目二：Transformer 原理与软件部署小实验

### 1. 基础条件

输入序列包含 3 个 Token，每个 Token 的特征维度为 4：

$$
X\in\mathbb{R}^{3\times4}
$$

采用单头自注意力，并设：

- $d_{model}=d_k=d_v=4$；
- $W_Q,W_K,W_V,W_O\in\mathbb{R}^{4\times4}$；
- 前馈网络隐藏维度 $d_{ff}=8$；
- $W_1\in\mathbb{R}^{4\times8}$、$b_1\in\mathbb{R}^{8}$；
- $W_2\in\mathbb{R}^{8\times4}$、$b_2\in\mathbb{R}^{4}$；
- 激活函数使用 ReLU；
- 权重由 `numpy.random.default_rng(0)` 生成；
- 暂不考虑 Dropout 和训练过程。

注意力计算为：

$$
Q=XW_Q,\qquad K=XW_K,\qquad V=XW_V
$$

$$
S=\frac{QK^T}{\sqrt{d_k}},\qquad
P=\operatorname{softmax}(S),\qquad
\operatorname{Attention}(X)=(PV)W_O
$$

### 2. 原理与维度

1. 写出 $X$、各权重、$Q$、$K$、$V$、$S$、$P$、$PV$ 和注意力输出的维度。
2. 用自己的语言解释 Query、Key 和 Value 的作用。
3. 解释注意力矩阵第 $i$ 行第 $j$ 列元素的含义。
4. 说明点积结果为什么除以 $\sqrt{d_k}$。
5. 说明 Softmax 后每一行元素之和为什么接近 1。
6. 分析序列长度由 $N$ 增加到 $2N$ 后，注意力矩阵的尺寸和存储量如何变化。

### 3. NumPy 实现

使用 NumPy 实现：

```python
def softmax(x):
    pass

def layer_norm(x, eps=1e-5):
    pass

def self_attention(x, Wq, Wk, Wv, Wo):
    pass

def feed_forward(x, W1, b1, W2, b2):
    pass

def transformer_block(x, parameters):
    pass
```

Transformer Block 采用：

$$
H_1=\operatorname{LayerNorm}\bigl(X+\operatorname{Attention}(X)\bigr)
$$

$$
H_2=\operatorname{LayerNorm}\bigl(H_1+\operatorname{FFN}(H_1)\bigr)
$$

LayerNorm 沿最后一个维度计算，使用 $\varepsilon=10^{-5}$。Softmax 应先减去每行最大值，以避免指数溢出。

程序输出各步骤的张量维度、注意力矩阵和最终结果，并自动检查：

- 注意力矩阵每行之和接近 1；
- 残差连接两侧形状相同；
- LayerNorm 后每个 Token 的均值接近 0；
- 输入较大正负数时不出现 `inf` 或 `nan`；
- 略微修改第一个 Token 后，注意力矩阵和最终输出发生合理变化。

### 4. 基础优化：QKV 融合

分别计算 Q、K、V：

```python
Q = X @ Wq
K = X @ Wk
V = X @ Wv
```

再改为融合计算：

```python
Wqkv = np.concatenate([Wq, Wk, Wv], axis=-1)
qkv = X @ Wqkv
Q, K, V = np.split(qkv, 3, axis=-1)
```

完成以下比较：

1. 验证两种实现的 $Q$、$K$、$V$ 和最终输出一致；
2. 比较矩阵乘法调用次数，并说明理论乘加次数是否变化；
3. 使用 $X\in\mathbb{R}^{128\times64}$ 和三个 `64×64` 权重矩阵进行简单计时；
4. `Wqkv` 在计时前只拼接一次，两种实现均先预热，再重复运行并取中位时间；
5. 解释融合为什么可能减少函数调用和中间数据访问，但在小矩阵上不一定明显加速。

### 5. 软件部署小实验

从下面两个小实验中选择一个。两者都只需使用小矩阵，不要求下载预训练模型。

#### 方向 A：简单 KV Cache

在单层因果自注意力中模拟逐 Token 解码：

1. 实现“每生成一个新 Token，就重新计算全部历史 K、V”的基线；
2. 实现简单缓存，把已有的 K、V 保存下来，新一步只计算新 Token 的 K、V；
3. 比较两种方法最后一个 Token 的输出，确认结果一致；
4. 统计两种方法重复计算的 K、V 元素数量；
5. 用下式估算缓存容量：

$$
2\times B\times L\times T\times H_{kv}\times d_h\times s_{byte}
$$

其中 2 表示 K 和 V，$B$ 为批量大小，$L$ 为层数，$T$ 为已缓存长度，$H_{kv}$ 为 KV 头数，$d_h$ 为头维度，$s_{byte}$ 为每个元素的字节数。

#### 方向 B：简单 INT8 权重量化

对 $W_Q$、$W_K$、$W_V$ 分别进行对称 INT8 量化：

$$
s=\frac{\max |W|}{127},\qquad
W_{int8}=\operatorname{round}\left(\frac{W}{s}\right)
$$

计算时先反量化：

$$
\hat W=sW_{int8}
$$

完成以下比较：

1. 比较浮点权重与 INT8 权重所需的存储字节数；
2. 比较量化前后的 $Q$、$K$、$V$，记录最大绝对误差；
3. 比较最终 Transformer Block 输出的变化；
4. 说明“权重存储更小”为什么不等于 NumPy 程序一定运行得更快。

### 6. 本题结果记录

记录完整 NumPy 代码、张量维度、关键中间结果、正确性检查、QKV 融合对比，以及所选部署小实验的结果和简要分析。

---

## 参考资料

- [Transformers：Cache strategies](https://huggingface.co/docs/transformers/kv_cache)
- [ONNX Runtime：模型量化](https://onnxruntime.ai/docs/performance/model-optimizations/quantization.html)
- [GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints](https://arxiv.org/abs/2305.13245)
- [FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness](https://arxiv.org/abs/2205.14135)

KV Cache、低比特量化和访存感知注意力都是当前 Transformer 推理优化的重要方向。本作业只要求完成前两者中的一个小实验；GQA 和 FlashAttention 作为了解材料，不要求复现。
