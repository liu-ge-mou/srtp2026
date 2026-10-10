module mul7_4(
    input [6:0]A,
    input [3:0]B,
    output [10:0]res
);

assign node0 = A[0]*B[0];
assign node1 = A[1]*B[0];
assign node2 = A[2]*B[0];
assign node3 = A[3]*B[0];
assign node4 = A[4]*B[0];
assign node5 = A[5]*B[0];
assign node6 = A[6]*B[0];

assign node7  = A[0]*B[1];
assign node8  = A[1]*B[1];
assign node9  = A[2]*B[1];
assign node10 = A[3]*B[1];
assign node11 = A[4]*B[1];
assign node12 = A[5]*B[1];
assign node13 = A[6]*B[1];

assign node14 = A[0]*B[2];
assign node15 = A[1]*B[2];
assign node16 = A[2]*B[2];
assign node17 = A[3]*B[2];
assign node18 = A[4]*B[2];
assign node19 = A[5]*B[2];
assign node20 = A[6]*B[2];

assign node21 = A[0]*B[3];
assign node22 = A[1]*B[3];
assign node23 = A[2]*B[3];
assign node24 = A[3]*B[3];
assign node25 = A[4]*B[3];
assign node26 = A[5]*B[3];
assign node27 = A[6]*B[3];

assign node28 = node26 & node20;
assign node29 = node26 | node20;
assign node30 = node25 | node19;
assign node31 = node30 | node13;
assign node32 = node24 | node18;
assign node34 = ~(node32 | node12);
assign node35 = ~node34;
assign node36 = node17 | node11;
assign node37 = node6 | node36;
assign node38 = node37 | node5;
assign node39 = node23 | node38;
assign node40 = ~(node22 | node16);
assign node41 = ~node10;
assign node42 = ~(node40 & node41);
assign node43 = node4 | node21;
assign node44 = node9 | node43;
assign node45 = node44 | node15;
assign node46 = node45 | node3;
assign node47 = node14 | node8;
assign node48 = node47 | node2;
assign node49 = node7 | node1;

assign res = {node28,node27,node29,node31,node35,node39,node42,node46,node48,node49,node0};

endmodule