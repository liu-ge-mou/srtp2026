
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 00:39:58
// Design Name: 
// Module Name: systolic_array_conv
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
`timescale 1ns / 1ps
`define DATA_SIZE 8         // 数据位宽
`define KERNEL_SIZE 5       // 卷积核大小
`define halfword_width 16   // 半字宽度，用于结果输出
`define inputMapWidth  6*6*8 // 6×6输入图像，8位宽
`define kernelWidth  5*5*8  // 5×5卷积核，8位宽

module systolic_array_conv(
    input clk, rst,
    
    input iwVld, imVld,    // 权重和输入有效信号
    input [`kernelWidth-1:0] weights,  // 5×5卷积核权重
    input [`DATA_SIZE-1:0] bia,        // 偏置值
    
    // 5×5输入块的五行数据，再乘以4
    input [`KERNEL_SIZE*`DATA_SIZE-1:0] map11, map12, map13, map14, map15,map21, map22, map23, map24, map25,map31,map32,map33,map34,map35,map41,map42,map43,map44,map45,
    
     // 卷积和输出
    output reg[`halfword_width-1:0] covSum1, covSum2,covSum3,covSum4,
 
    output reg covResVld                    // 结果有效信号
);

    // 定义脉动阵列的内部信号
    wire [`DATA_SIZE-1:0] w11, w12, w13, w14, w15;  // 第一行权重
    wire [`DATA_SIZE-1:0] w16, w17, w18, w19, w110;  // 第二行权重
    wire [`DATA_SIZE-1:0] w111, w112, w113, w114, w115;  // 第三行权重
    wire [`DATA_SIZE-1:0] w116, w117, w118, w119, w120;  // 第四行权重
    wire [`DATA_SIZE-1:0] w121, w122, w123, w124, w125;  // 第五行权重
    
    // 提取卷积核权重
    assign w11 = weights[`kernelWidth-1 - 0*40:`kernelWidth - 0*40 - `DATA_SIZE];
    assign w12 = weights[`kernelWidth-1 - 0*40 - `DATA_SIZE:`kernelWidth - 0*40 - 2*`DATA_SIZE];
    assign w13 = weights[`kernelWidth-1 - 0*40 - 2*`DATA_SIZE:`kernelWidth - 0*40 - 3*`DATA_SIZE];
    assign w14 = weights[`kernelWidth-1 - 0*40 - 3*`DATA_SIZE:`kernelWidth - 0*40 - 4*`DATA_SIZE];
    assign w15 = weights[`kernelWidth-1 - 0*40 - 4*`DATA_SIZE:`kernelWidth - 0*40 - 5*`DATA_SIZE];
    
    assign w16 = weights[`kernelWidth-1 - 1*40:`kernelWidth - 1*40 - `DATA_SIZE];
    assign w17 = weights[`kernelWidth-1 - 1*40 - `DATA_SIZE:`kernelWidth - 1*40 - 2*`DATA_SIZE];
    assign w18 = weights[`kernelWidth-1 - 1*40 - 2*`DATA_SIZE:`kernelWidth - 1*40 - 3*`DATA_SIZE];
    assign w19 = weights[`kernelWidth-1 - 1*40 - 3*`DATA_SIZE:`kernelWidth - 1*40 - 4*`DATA_SIZE];
    assign w110 = weights[`kernelWidth-1 - 1*40 - 4*`DATA_SIZE:`kernelWidth - 1*40 - 5*`DATA_SIZE];
    
    assign w111 = weights[`kernelWidth-1 - 2*40:`kernelWidth - 2*40 - `DATA_SIZE];
    assign w112 = weights[`kernelWidth-1 - 2*40 - `DATA_SIZE:`kernelWidth - 2*40 - 2*`DATA_SIZE];
    assign w113 = weights[`kernelWidth-1 - 2*40 - 2*`DATA_SIZE:`kernelWidth - 2*40 - 3*`DATA_SIZE];
    assign w114 = weights[`kernelWidth-1 - 2*40 - 3*`DATA_SIZE:`kernelWidth - 2*40 - 4*`DATA_SIZE];
    assign w115 = weights[`kernelWidth-1 - 2*40 - 4*`DATA_SIZE:`kernelWidth - 2*40 - 5*`DATA_SIZE];
    
    assign w116 = weights[`kernelWidth-1 - 3*40:`kernelWidth - 3*40 - `DATA_SIZE];
    assign w117 = weights[`kernelWidth-1 - 3*40 - `DATA_SIZE:`kernelWidth - 3*40 - 2*`DATA_SIZE];
    assign w118 = weights[`kernelWidth-1 - 3*40 - 2*`DATA_SIZE:`kernelWidth - 3*40 - 3*`DATA_SIZE];
    assign w119 = weights[`kernelWidth-1 - 3*40 - 3*`DATA_SIZE:`kernelWidth - 3*40 - 4*`DATA_SIZE];
    assign w120 = weights[`kernelWidth-1 - 3*40 - 4*`DATA_SIZE:`kernelWidth - 3*40 - 5*`DATA_SIZE];
    
    assign w121 = weights[`kernelWidth-1 - 4*40:`kernelWidth - 4*40 - `DATA_SIZE];
    assign w122 = weights[`kernelWidth-1 - 4*40 - `DATA_SIZE:`kernelWidth - 4*40 - 2*`DATA_SIZE];
    assign w123 = weights[`kernelWidth-1 - 4*40 - 2*`DATA_SIZE:`kernelWidth - 4*40 - 3*`DATA_SIZE];
    assign w124 = weights[`kernelWidth-1 - 4*40 - 3*`DATA_SIZE:`kernelWidth - 4*40 - 4*`DATA_SIZE];
    assign w125 = weights[`kernelWidth-1 - 4*40 - 4*`DATA_SIZE:`kernelWidth - 4*40 - 5*`DATA_SIZE];
    
    // 提取四个输入的数据，也就是25乘以4
    wire [`DATA_SIZE-1:0] p11, p12, p13, p14, p15,p16,p17,p18,p19,p110,p111,p112,p113,p114,p115,p116,p117,p118,p119,p120,p121,p122,p123,p124,p125;  // first map s element
 wire [`DATA_SIZE-1:0] p21, p22, p23, p24, p25,p26,p27,p28,p29,p210,p211,p212,p213,p214,p215,p216,p217,p218,p219,p220,p221,p222,p223,p224,p225;  // 2s map s element
  wire [`DATA_SIZE-1:0] p31, p32, p33, p34, p35,p36,p37,p38,p39,p310,p311,p312,p313,p314,p315,p316,p317,p318,p319,p320,p321,p322,p323,p324,p325;  // 3 map s element
   wire [`DATA_SIZE-1:0] p41, p42, p43, p44, p45,p46,p47,p48,p49,p410,p411,p412,p413,p414,p415,p416,p417,p418,p419,p420,p421,p422,p423,p424,p425;  // 4 map s element  
   
    assign p11 = map11[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
    assign p12 = map11[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
    assign p13 = map11[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
    assign p14 = map11[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
    assign p15 = map11[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
    
    assign p16 = map12[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
    assign p17 = map12[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
    assign p18 = map12[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
    assign p19 = map12[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
    assign p110 = map12[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p111 = map13[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p112 = map13[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p113 = map13[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p114 = map13[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p115 = map13[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p116 = map14[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p117 = map14[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p118 = map14[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p119 = map14[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p120 = map14[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p121 = map15[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p122 = map15[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p123 = map15[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p124 = map15[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p125 = map15[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];

    assign p21 = map21[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
    assign p22 = map21[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
    assign p23 = map21[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
    assign p24 = map21[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
    assign p25 = map21[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
    
    assign p26 = map22[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
    assign p27 = map22[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
    assign p28 = map22[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
    assign p29 = map22[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
    assign p210 = map22[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p211 = map23[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p212 = map23[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p213 = map23[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p214 = map23[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p215 = map23[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p216 = map24[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p217 = map24[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p218 = map24[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p219 = map24[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p220 = map24[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p221 = map25[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p222 = map25[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p223 = map25[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p224 = map25[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p225 = map25[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];

    assign p31 = map31[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
    assign p32 = map31[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
    assign p33 = map31[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
    assign p34 = map31[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
    assign p35 = map31[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
    
    assign p36 = map32[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
    assign p37 = map32[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
    assign p38 = map32[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
    assign p39 = map32[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
    assign p310 = map32[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p311 = map33[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p312 = map33[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p313 = map33[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p314 = map33[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p315 = map33[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p316 = map34[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p317 = map34[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p318 = map34[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p319 = map34[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p320 = map34[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p321 = map35[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p322 = map35[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p323 = map35[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p324 = map35[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p325 = map35[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p41 = map41[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p42 = map41[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p43 = map41[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p44 = map41[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p45 = map41[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
        
        assign p46 = map42[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
        assign p47 = map42[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
        assign p48 = map42[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
        assign p49 = map42[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
        assign p410 = map42[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
            
            assign p411 = map43[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
            assign p412 = map43[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
            assign p413 = map43[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
            assign p414 = map43[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
            assign p415 = map43[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
            
            assign p416 = map44[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
            assign p417 = map44[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
            assign p418 = map44[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
            assign p419 = map44[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
            assign p420 = map44[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE];
            
            assign p421 = map45[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8:`KERNEL_SIZE*`DATA_SIZE - 0*8 - `DATA_SIZE];
            assign p422 = map45[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - `DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 2*`DATA_SIZE];
            assign p423 = map45[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 2*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 3*`DATA_SIZE];
            assign p424 = map45[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 3*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 4*`DATA_SIZE];
            assign p425 = map45[`KERNEL_SIZE*`DATA_SIZE-1 - 0*8 - 4*`DATA_SIZE:`KERNEL_SIZE*`DATA_SIZE - 0*8 - 5*`DATA_SIZE]; 
        
//四个寄存器
reg [`halfword_width - 1:0] reg1,reg2,reg3,reg4;
//实例化四个乘法器
reg [`KERNEL_SIZE*`DATA_SIZE - 1:0] p1,p2,p3,p4;
reg [`KERNEL_SIZE*`DATA_SIZE - 1:0] w1,w2,w3,w4;
wire [`halfword_width - 1:0] o1,o2,o3,o4;
wire [`halfword_width - 1:0] oo1,oo2,oo3,oo4;
multi mul1(.a(p1),.b(w1),.o(o1));
multi mul2(.a(p2),.b(w2),.o(o2));
multi mul3(.a(p3),.b(w3),.o(o3));
multi mul4(.a(p4),.b(w4),.o(o4));
//实例化四个加法器
add add1(.a(o1),.b(reg1),.o(oo1));
add add2(.a(o2),.b(reg2),.o(oo2));
add add3(.a(o3),.b(reg3),.o(oo3));
add add4(.a(o4),.b(reg4),.o(oo4));
//计数器
reg [4:0] counter;

// 定义带偏置的累加结果
    wire [`halfword_width-1:0] final_oo1 = (counter == 'd28) ? oo1 + bia : oo1;
    wire [`halfword_width-1:0] final_oo2 = (counter == 'd28) ? oo2 + bia : oo2;
    wire [`halfword_width-1:0] final_oo3 = (counter == 'd28) ? oo3 + bia : oo3;
    wire [`halfword_width-1:0] final_oo4 = (counter == 'd28) ? oo4 + bia : oo4;

//有效判断
reg data_Vld=0;
reg [1:0]Vld_cnt=0;

// 脉冲阵列搭建
    always @(posedge clk or posedge rst) begin
        if (rst) begin
      reg1<=0;reg2<=0;reg3<=0;reg4<=0;
      counter<=0;
      covSum1<=0;covSum2<=0;covSum3<=0;covSum4<=0;
      covResVld<=0;
      data_Vld<=0;Vld_cnt<=0;
      end
      else begin
        if(iwVld&&imVld)begin
        Vld_cnt<=Vld_cnt+1;
        data_Vld<=1;
        end
        else if(Vld_cnt>0) begin
        data_Vld<=1;
        end
        else begin
        data_Vld<=0;
        end
        if(data_Vld) begin
            if(counter=='d28)begin
      covSum1<=final_oo1;
      covSum2<=final_oo2;
      covSum3<=final_oo3;
      covSum4<=final_oo4;
      covResVld<=1;
             end
             else begin
        counter<=counter+1;
          reg1<=oo1;
          reg2<=oo2;
          reg3<=oo3;
          reg4<=oo4;
          covSum1<=covSum1;
          covSum2<=covSum2;
          covSum3<=covSum3;
          covSum4<=covSum4;
              end
         end
      else begin
      counter<=counter;
      end
      end
      end
     
      
      always@(*) begin
      case(counter)
      'd0:begin
      p1=p11;w1=w11;
      end
      'd1:begin
      p1=p12;w1=w12;
      p2=p21;w2=w11;
      end
      'd2:begin
      p1=p13;w1=w13;
      p2=p22;w2=w12;
      p3=p31;w3=w11;
      end
      'd3:begin
      p1=p14;w1=w14;
      p2=p23;w2=w13;
      p3=p32;w3=w12;
      p4=p41;w4=w11;
      end
      'd4:begin
      p1=p15;w1=w15;
      p2=p24;w2=w14;
      p3=p33;w3=w13;
      p4=p42;w4=w12;
      end
      'd5:begin
      p1=p16;w1=w16;
      p2=p25;w2=w15;
      p3=p34;w3=w14;
      p4=p43;w4=w13;
      end     
      'd6:begin
      p1=p17;w1=w17;
      p2=p26;w2=w16;
      p3=p35;w3=w15;
      p4=p44;w4=w14;
      end    
      'd7:begin
      p1=p18;w1=w18;
      p2=p27;w2=w17;
      p3=p36;w3=w16;
      p4=p45;w4=w15;
      end
      'd8:begin
      p1=p19;w1=w19;
      p2=p28;w2=w18;
      p3=p37;w3=w17;
      p4=p46;w4=w16;
      end      
      'd9:begin
      p1=p110;w1=w110;
      p2=p29;w2=w19;
      p3=p38;w3=w18;
      p4=p47;w4=w17;
      end
      'd10:begin
      p1=p111;w1=w111;
      p2=p210;w2=w110;
      p3=p39;w3=w19;
      p4=p48;w4=w18;
      end
      'd11:begin
      p1=p112;w1=w112;
      p2=p211;w2=w111;
      p3=p310;w3=w110;
      p4=p49;w4=w19;
      end
      'd12:begin
      p1=p113;w1=w113;
      p2=p212;w2=w112;
      p3=p311;w3=w111;
      p4=p410;w4=w110;
      end
      'd13:begin
      p1=p114;w1=w114;
      p2=p213;w2=w113;
      p3=p312;w3=w112;
      p4=p411;w4=w111;
      end
      'd14:begin
      p1=p115;w1=w115;
      p2=p214;w2=w114;
      p3=p313;w3=w113;
      p4=p412;w4=w112;
      end
      'd15:begin
      p1=p116;w1=w116;
      p2=p215;w2=w115;
      p3=p314;w3=w114;
      p4=p413;w4=w113;
      end
      'd16:begin
      p1=p117;w1=w117;
      p2=p216;w2=w116;
      p3=p315;w3=w115;
      p4=p414;w4=w114;
      end
      'd17:begin
      p1=p118;w1=w118;
      p2=p217;w2=w117;
      p3=p316;w3=w116;
      p4=p415;w4=w115;
      end
      'd18:begin
      p1=p119;w1=w119;
      p2=p218;w2=w118;
      p3=p317;w3=w117;
      p4=p416;w4=w116;
      end
      'd19:begin
      p1=p120;w1=w120;
      p2=p219;w2=w119;
      p3=p318;w3=w118;
      p4=p417;w4=w117;
      end      
      'd20:begin
      p1=p121;w1=w121;
      p2=p220;w2=w120;
      p3=p319;w3=w119;
      p4=p418;w4=w118;
      end     
      'd21:begin
      p1=p122;w1=w122;
      p2=p221;w2=w121;
      p3=p320;w3=w120;
      p4=p419;w4=w119;
      end    
      'd22:begin
          p1=p123;w1=w123;
          p2=p222;w2=w122;
          p3=p321;w3=w121;
          p4=p420;w4=w120;
          end
      'd23:begin
          p1=p124;w1=w124;
          p2=p223;w2=w123;
          p3=p322;w3=w122;
          p4=p421;w4=w121;
          end
      'd24:begin
          p1=p125;w1=w125;
          p2=p224;w2=w124;
          p3=p323;w3=w123;
          p4=p422;w4=w122;
          end
      'd25:begin
          p2=p225;w2=w125;
          p3=p324;w3=w124;
          p4=p423;w4=w123;
          end
      'd26:begin
          p3=p325;w3=w125;
          p4=p424;w4=w124;
          end
      'd27:begin
          p4=p425;w4=w125;
        end
        'd28:begin
        p1=0;w1=0;
        p2=0;w2=0;
        p3=0;w3=0;
        p4=0;w4=0;
        end
        default:begin
        p1=0;w1=0;
        p2=0;w2=0;
        p3=0;w3=0;
        p4=0;w4=0;
        end
     endcase
     end
     
     endmodule
 