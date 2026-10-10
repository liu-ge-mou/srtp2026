`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/06 16:50:38
// Design Name: 
// Module Name: accumulator
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


module accumulator(
    input clk,
    input rst,
    input en,
    input [15:0] din,
    output reg [15:0] acc
    );

    always @(posedge clk) begin
        if (rst) begin
            acc <= 16'b0;
        end else if (en) begin
            acc <= acc + din;
        end
    end
endmodule

