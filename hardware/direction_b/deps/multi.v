 `timescale 1ns/1ps
 //近似计算的乘法器为无符号数计算，因此�?要加�?个外壳，该乘法器在负数运算时与原lab3的乘法器设计保持�?致，即负数不用反码计算�??
 module multi(
 input [7:0] a,
 input [7:0] b,

 output [15:0] o
 );
 
 wire [13:0] res1;

mul inst_mul(.A(a[6:0]), .B(b[6:0]), .res(res1));

 assign o = {a[7]^b[7],1'b0,res1[13:0]};
 endmodule


