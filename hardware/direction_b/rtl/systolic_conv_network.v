//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/30 00:18:29
// Design Name: 
// Module Name: systolic_conv_network
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
`timescale 1ns/1ps
`define DATA_SIZE 8         // 数据位宽
`define KERNEL_SIZE 5       // 卷积核大小
`define halfword_width 16   // 半字宽度，用于结果输出
`define inputMapWidth  6*6*8 // 6×6输入图像，8位宽
`define kernelWidth  5*5*8  // 5×5卷积核，8位宽


module systolic_conv_network(
    input clk, rst,              // 时钟和复位
    
    input iwVld, imVld,          // 权重和输入图像有效信号
    input [`inputMapWidth-1:0] im,    // 输入图像数据
    input [`kernelWidth-1:0] iw,      // 卷积核权重
    input [`DATA_SIZE-1:0] ib,        // 偏置值
    
    output covResVld,             // 输出结果有效信号
    output[`halfword_width-1:0] out1, out2, out3, out4  // 四个输出结果
);

    
    // 分块输入图像数据
    wire [`KERNEL_SIZE*`DATA_SIZE-1:0] im_block1_1, im_block1_2, im_block1_3, im_block1_4, im_block1_5;
    wire [`KERNEL_SIZE*`DATA_SIZE-1:0] im_block2_1, im_block2_2, im_block2_3, im_block2_4, im_block2_5;
    wire [`KERNEL_SIZE*`DATA_SIZE-1:0] im_block3_1, im_block3_2, im_block3_3, im_block3_4, im_block3_5;
    wire [`KERNEL_SIZE*`DATA_SIZE-1:0] im_block4_1, im_block4_2, im_block4_3, im_block4_4, im_block4_5;
    
    // 输入图像分块逻辑
    // 第一组5×5输入块（左上角）
    assign im_block1_1 = im[`inputMapWidth-1 - 0*48:`inputMapWidth - 0*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block1_2 = im[`inputMapWidth-1 - 1*48:`inputMapWidth - 1*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block1_3 = im[`inputMapWidth-1 - 2*48:`inputMapWidth - 2*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block1_4 = im[`inputMapWidth-1 - 3*48:`inputMapWidth - 3*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block1_5 = im[`inputMapWidth-1 - 4*48:`inputMapWidth - 4*48 - `KERNEL_SIZE*`DATA_SIZE];
    
    // 第二组5×5输入块（右上角偏移）
    assign im_block2_1 = im[`inputMapWidth-1 - 0*48 - `DATA_SIZE:`inputMapWidth - 0*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block2_2 = im[`inputMapWidth-1 - 1*48 - `DATA_SIZE:`inputMapWidth - 1*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block2_3 = im[`inputMapWidth-1 - 2*48 - `DATA_SIZE:`inputMapWidth - 2*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block2_4 = im[`inputMapWidth-1 - 3*48 - `DATA_SIZE:`inputMapWidth - 3*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block2_5 = im[`inputMapWidth-1 - 4*48 - `DATA_SIZE:`inputMapWidth - 4*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    
    // 第三组5×5输入块（左下角偏移）
    assign im_block3_1 = im[`inputMapWidth-1 - 1*48:`inputMapWidth - 1*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block3_2 = im[`inputMapWidth-1 - 2*48:`inputMapWidth - 2*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block3_3 = im[`inputMapWidth-1 - 3*48:`inputMapWidth - 3*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block3_4 = im[`inputMapWidth-1 - 4*48:`inputMapWidth - 4*48 - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block3_5 = im[`inputMapWidth-1 - 5*48:`inputMapWidth - 5*48 - `KERNEL_SIZE*`DATA_SIZE];
    
    // 第四组5×5输入块（右下角偏移）
    assign im_block4_1 = im[`inputMapWidth-1 - 1*48 - `DATA_SIZE:`inputMapWidth - 1*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block4_2 = im[`inputMapWidth-1 - 2*48 - `DATA_SIZE:`inputMapWidth - 2*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block4_3 = im[`inputMapWidth-1 - 3*48 - `DATA_SIZE:`inputMapWidth - 3*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block4_4 = im[`inputMapWidth-1 - 4*48 - `DATA_SIZE:`inputMapWidth - 4*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    assign im_block4_5 = im[`inputMapWidth-1 - 5*48 - `DATA_SIZE:`inputMapWidth - 5*48 - `DATA_SIZE - `KERNEL_SIZE*`DATA_SIZE];
    
    // 实例化脉动阵列卷积模块
    systolic_array_conv u_systolic_array1(
        .clk(clk), .rst(rst),
        .iwVld(iwVld), .imVld(imVld),
        .weights(iw), .bia(ib),
        .map11(im_block1_1), .map12(im_block1_2),
        .map13(im_block1_3), .map14(im_block1_4),
        .map15(im_block1_5),
        .map21(im_block2_1), .map22(im_block2_2),
        .map23(im_block2_3), .map24(im_block2_4),
        .map25(im_block2_5),        
                .map31(im_block3_1), .map32(im_block3_2),
        .map33(im_block3_3), .map34(im_block3_4),
        .map35(im_block3_5),
        .map41(im_block4_1), .map42(im_block4_2),
        .map43(im_block4_3), .map44(im_block4_4),
        .map45(im_block4_5),  
        .covSum1(out1),
        .covSum2(out2),
                .covSum3(out3),
                        .covSum4(out4),
                        .covResVld(covResVld)
    );
    
    endmodule

