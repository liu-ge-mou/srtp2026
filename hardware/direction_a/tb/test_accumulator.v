`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/09 09:46:02
// Design Name: 
// Module Name: test_accumulator
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



module test_accumulator;

reg clk;
reg rst;
reg en;
reg [7:0] din;

wire [15:0] acc;

accumulator uut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .din(din),
    .acc(acc)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

task check_acc;
    input [15:0] expected;
    begin
        if (acc !== expected) begin
            $display("FAIL: time=%0t, acc=%0d, expected=%0d",
                     $time, acc, expected);
        end
        else begin
            $display("PASS: time=%0t, acc=%0d",
                     $time, acc);
        end
    end
endtask

initial begin
    rst = 1;
    en  = 0;
    din = 8'd0;

    // First rising edge: synchronous reset
    #6;
    check_acc(16'd0);

    // Add 3 at the next rising edge
    rst = 0;
    en  = 1;
    din = 8'd3;
    #10;
    check_acc(16'd3);

    // Add 4
    din = 8'd4;
    #10;
    check_acc(16'd7);

    // en=0: acc must remain 7
    en  = 0;
    din = 8'd100;
    #10;
    check_acc(16'd7);

    // Add 2
    en  = 1;
    din = 8'd2;
    #10;
    check_acc(16'd9);

    $display("TEST FINISHED");
    $finish;
end

endmodule
