module pe(
    input clk,
    input rst,

    // 左侧输入 A，向右传递
    input [7:0] a_in,
    input       a_valid_in,
    output reg [7:0] a_out,
    output reg       a_valid_out,

    // 上方输入 B，向下传递
    input [7:0] b_in,
    input       b_valid_in,
    output reg [7:0] b_out,
    output reg       b_valid_out,

    // 本 PE 的累加结果
    output [15:0] acc

);

wire [15:0] product;
wire        mac_en;

// 两个 8 位无符号数相乘，结果扩展为 16 位。
assign product = {8'd0, a_in} * {8'd0, b_in};

// A 和 B 同时有效，且两者均非零时，执行一次乘累加。
assign mac_en = a_valid_in && b_valid_in
                && (a_in != 8'd0)
                && (b_in != 8'd0);

// 使用独立累加器模块保存部分和。
accumulator u_accumulator (
    .clk(clk),
    .rst(rst),
    .en(mac_en),
    .din(product),
    .acc(acc)
);

// A 向右、B 向下传递；每经过一个 PE 延迟一个时钟周期。
always @(posedge clk) begin
    if (rst) begin
        a_out       <= 8'd0;
        a_valid_out <= 1'b0;
        b_out       <= 8'd0;
        b_valid_out <= 1'b0;
    end
    else begin
        a_out       <= a_in;
        a_valid_out <= a_valid_in;

        b_out       <= b_in;
        b_valid_out <= b_valid_in;
    end
end

endmodule