`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/11 18:28:35
// Design Name: 
// Module Name: test_pe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module test_pe;

reg clk;
reg rst;

reg [7:0] a_in;
reg       a_valid_in;

reg [7:0] b_in;
reg       b_valid_in;

wire [7:0]  a_out;
wire        a_valid_out;

wire [7:0]  b_out;
wire        b_valid_out;

wire [15:0] acc;

// 被测试模块
pe uut (
    .clk(clk),
    .rst(rst),

    .a_in(a_in),
    .a_valid_in(a_valid_in),
    .a_out(a_out),
    .a_valid_out(a_valid_out),

    .b_in(b_in),
    .b_valid_in(b_valid_in),
    .b_out(b_out),
    .b_valid_out(b_valid_out),

    .acc(acc)
);

// 时钟周期 10 ns
always #5 clk = ~clk;

// 检查结果
task check_result;
    input [15:0] expected_acc;
    input [7:0]  expected_a_out;
    input        expected_a_valid;
    input [7:0]  expected_b_out;
    input        expected_b_valid;

    begin
        #1;
        if (acc !== expected_acc ||
            a_out !== expected_a_out ||
            a_valid_out !== expected_a_valid ||
            b_out !== expected_b_out ||
            b_valid_out !== expected_b_valid) begin

            $display("FAIL at time %0t", $time);
            $display("acc: expected=%d, actual=%d", expected_acc, acc);
            $display("a_out: expected=%d, actual=%d", expected_a_out, a_out);
            $display("a_valid_out: expected=%b, actual=%b",
                     expected_a_valid, a_valid_out);
            $display("b_out: expected=%d, actual=%d", expected_b_out, b_out);
            $display("b_valid_out: expected=%b, actual=%b",
                     expected_b_valid, b_valid_out);
        end
        else begin
            $display("PASS at time %0t: acc = %d", $time, acc);
        end
    end
endtask

initial begin
    // 初始状态
    clk = 1'b0;
    rst = 1'b1;

    a_in = 8'd0;
    a_valid_in = 1'b0;

    b_in = 8'd0;
    b_valid_in = 1'b0;

    // 第一个上升沿：同步复位
    @(posedge clk);
    check_result(16'd0, 8'd0, 1'b0, 8'd0, 1'b0);

    // 第一次乘加：1 × 5，acc = 5
    @(negedge clk);
    rst = 1'b0;
    a_in = 8'd1;
    b_in = 8'd5;
    a_valid_in = 1'b1;
    b_valid_in = 1'b1;

    @(posedge clk);
    check_result(16'd5, 8'd1, 1'b1, 8'd5, 1'b1);

    // 第二次乘加：2 × 7，acc = 5 + 14 = 19
    @(negedge clk);
    a_in = 8'd2;
    b_in = 8'd7;
    a_valid_in = 1'b1;
    b_valid_in = 1'b1;

    @(posedge clk);
    check_result(16'd19, 8'd2, 1'b1, 8'd7, 1'b1);

    // 无效周期：输入虽为 9，但不允许乘加，acc 保持 19
    @(negedge clk);
    a_in = 8'd9;
    b_in = 8'd9;
    a_valid_in = 1'b0;
    b_valid_in = 1'b0;

    @(posedge clk);
    check_result(16'd19, 8'd9, 1'b0, 8'd9, 1'b0);

    // 中途复位：所有寄存器回到 0
    @(negedge clk);
    rst = 1'b1;

    @(posedge clk);
    check_result(16'd0, 8'd0, 1'b0, 8'd0, 1'b0);

    // 复位后重新计算：3 × 4 = 12
    @(negedge clk);
    rst = 1'b0;
    a_in = 8'd3;
    b_in = 8'd4;
    a_valid_in = 1'b1;
    b_valid_in = 1'b1;

    @(posedge clk);
    check_result(16'd12, 8'd3, 1'b1, 8'd4, 1'b1);

    $display("Simulation finished.");
    $finish;
end

endmodule