`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/12 03:50:30
// Design Name: 
// Module Name: systolic_array_2x2
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


module systolic_array_2x2(
    
    input             clk,
    input             rst,
    input             start,

    input      [7:0]  a_row0_in,
    input      [7:0]  a_row1_in,
    input      [7:0]  b_col0_in,
    input      [7:0]  b_col1_in,

    input             a_row0_valid_in,
    input             a_row1_valid_in,
    input             b_col0_valid_in,
    input             b_col1_valid_in,

    output     [15:0] c00,
    output     [15:0] c01,
    output     [15:0] c10,
    output     [15:0] c11,
    output reg        done
);

    // start 被采样后，阵列按固定协议接收四拍错位输入数据。
    // 第四个计算上升沿结束时，p11 完成最后一次乘加，done 拉高一拍。
    reg       busy;
    reg [1:0] compute_count;

    always @(posedge clk) begin
        if (rst) begin
            busy          <= 1'b0;
            compute_count <= 2'd0;
            done          <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    busy          <= 1'b1;
                    compute_count <= 2'd0;
                end
            end else if (compute_count == 2'd3) begin
                busy          <= 1'b0;
                compute_count <= 2'd0;
                done          <= 1'b1;
            end else begin
                compute_count <= compute_count + 1'b1;
            end
        end
    end

    wire [7:0] a00_to_01;
    wire [7:0] a10_to_11;
    wire [7:0] b00_to_10;
    wire [7:0] b01_to_11;

    wire a00_valid_to_01;
    wire a10_valid_to_11;
    wire b00_valid_to_10;
    wire b01_valid_to_11;

    wire [7:0] unused_a01_out;
    wire [7:0] unused_b10_out;
    wire [7:0] unused_a11_out;
    wire [7:0] unused_b11_out;

    wire unused_a01_valid_out;
    wire unused_b10_valid_out;
    wire unused_a11_valid_out;
    wire unused_b11_valid_out;

    // 左上角 PE：计算 c00
    pe p00 (
        .clk(clk),
        .rst(rst),
        .a_in(a_row0_in),
        .b_in(b_col0_in),
        .a_valid_in(a_row0_valid_in),
        .b_valid_in(b_col0_valid_in),
        .a_out(a00_to_01),
        .b_out(b00_to_10),
        .a_valid_out(a00_valid_to_01),
        .b_valid_out(b00_valid_to_10),
        .acc(c00)
    );

    // 右上角 PE：计算 c01
    pe p01 (
        .clk(clk),
        .rst(rst),
        .a_in(a00_to_01),
        .b_in(b_col1_in),
        .a_valid_in(a00_valid_to_01),
        .b_valid_in(b_col1_valid_in),
        .a_out(unused_a01_out),
        .b_out(b01_to_11),
        .a_valid_out(unused_a01_valid_out),
        .b_valid_out(b01_valid_to_11),
        .acc(c01)
    );

    // 左下角 PE：计算 c10
    pe p10 (
        .clk(clk),
        .rst(rst),
        .a_in(a_row1_in),
        .b_in(b00_to_10),
        .a_valid_in(a_row1_valid_in),
        .b_valid_in(b00_valid_to_10),
        .a_out(a10_to_11),
        .b_out(unused_b10_out),
        .a_valid_out(a10_valid_to_11),
        .b_valid_out(unused_b10_valid_out),
        .acc(c10)
    );

    // 右下角 PE：计算 c11
    pe p11 (
        .clk(clk),
        .rst(rst),
        .a_in(a10_to_11),
        .b_in(b01_to_11),
        .a_valid_in(a10_valid_to_11),
        .b_valid_in(b01_valid_to_11),
        .a_out(unused_a11_out),
        .b_out(unused_b11_out),
        .a_valid_out(unused_a11_valid_out),
        .b_valid_out(unused_b11_valid_out),
        .acc(c11)
    );

endmodule
