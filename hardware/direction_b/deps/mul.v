module mul(
    input [6:0] A,
    input [6:0] B,
    output [13:0] res
);

wire [9:0]res1;
wire [10:0]res2;

assign res1 = A * B[6:4];
mul7_4 u_mul(
    .A(A),
    .B(B[3:0]),
    .res(res2)
);

assign res = {res1,4'b0} + res2;

endmodule 