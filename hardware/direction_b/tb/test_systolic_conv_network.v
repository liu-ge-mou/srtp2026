//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 11:25:13
// Design Name: 
// Module Name: test_systolic_conv_network
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


module test_systolic_conv_network;

    // 时钟和复位信号
    reg clk = 0;
    reg rst = 1;
    
    // 输入信号
    reg iwVld = 0;
    reg imVld = 0;
    reg [`inputMapWidth-1:0] im = 0;
    reg [`kernelWidth-1:0] iw = 0;
    reg [`DATA_SIZE-1:0] ib = 0;
    
    // 输出信号
    wire covResVld;
    wire[`halfword_width-1:0] out1, out2, out3, out4;
    
    // 计数器和时间测量
    reg [31:0] cycle_count = 0;
    reg start_time = 0;
    reg end_time = 0;
    reg [31:0] start_cycle = 0;
    reg [31:0] end_cycle = 0;
    
    // 实例化被测设计
    systolic_conv_network u_dut (
        .clk(clk),
        .rst(rst),
        .iwVld(iwVld),
        .imVld(imVld),
        .im(im),
        .iw(iw),
        .ib(ib),
        .covResVld(covResVld),
        .out1(out1),
        .out2(out2),
        .out3(out3),
        .out4(out4)
    );
    
    // 生成时钟
    always #5 clk = ~clk;  // 100MHz时钟，周期10ns
    
    // 初始化测试
    initial begin
        // 初始化输入
        im = 0;
        iw = 0;
        ib = 10;  // 偏置设为10
        
        // 复位系统
        rst = 1;
        #20 rst = 0;
        
        // 生成测试数据
        generate_test_data();
        
        // 等待处理完成
        wait(covResVld === 1);
        #10;  // 确保输出稳定


       
    end
    
    // 生成测试数据的task（修正了语法和变量声明）
    task generate_test_data;
        integer i, j;  // 明确声明循环变量
        reg [`DATA_SIZE-1:0] image_data[0:5][0:5];  // 6x6图像存储
        reg [`DATA_SIZE-1:0] kernel_data[0:4][0:4];  // 5x5卷积核存储
        
        begin
            // 初始化图像数据 (简单的递增模式)
            for (i = 0; i < 6; i = i + 1) begin
                for (j = 0; j < 6; j = j + 1) begin
                    image_data[i][j] = i * 6 + j + 1;  // 简单的测试数据
                end
            end
            
            // 初始化卷积核数据 (简单的全1矩阵)
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    kernel_data[i][j] = 1;  // 全1卷积核
                end
            end
            
            // 将图像数据转换为向量格式
            for (i = 0; i < 6; i = i + 1) begin
                for (j = 0; j < 6; j = j + 1) begin
                    im[(i*6 + j)*`DATA_SIZE +:`DATA_SIZE] = image_data[i][j];
                end
            end
            
            // 将卷积核数据转换为向量格式
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    iw[(i*5 + j)*`DATA_SIZE +:`DATA_SIZE] = kernel_data[i][j];
                end
            end
            
            // 启动数据输入
            #100;  // 等待系统稳定
            iwVld = 1;
            imVld = 1;
            start_time = 1;  // 标记开始时间
        end
    endtask
    
    // 监测时钟周期，记录开始和结束时间
    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
        
        if (start_time && start_cycle == 0) begin
            start_cycle = cycle_count;
            start_time = 0;
        end
        
        if (covResVld === 1 && end_cycle == 0) begin
            end_cycle = cycle_count;
            end_time = 1;
        end
    end

endmodule