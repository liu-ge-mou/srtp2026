module test_systolic_array_2x2;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] a_row0_in;
    reg [7:0] a_row1_in;
    reg [7:0] b_col0_in;
    reg [7:0] b_col1_in;
    reg a_row0_valid_in;
    reg a_row1_valid_in;
    reg b_col0_valid_in;
    reg b_col1_valid_in;
    wire [15:0] c00;
    wire [15:0] c01;
    wire [15:0] c10;
    wire [15:0] c11;
    wire done;
    integer failures;
    integer baseline_mac_count;
    integer actual_mac_count;

    systolic_array_2x2 uut (
        .clk(clk), .rst(rst), .start(start),
        .a_row0_in(a_row0_in), .a_row1_in(a_row1_in),
        .b_col0_in(b_col0_in), .b_col1_in(b_col1_in),
        .a_row0_valid_in(a_row0_valid_in),
        .a_row1_valid_in(a_row1_valid_in),
        .b_col0_valid_in(b_col0_valid_in),
        .b_col1_valid_in(b_col1_valid_in),
        .c00(c00), .c01(c01), .c10(c10), .c11(c11), .done(done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // baseline：只要 A、B 都有效，就认为原始阵列会执行一次 MAC。
    // actual：读取每个 PE 的 mac_en，统计零值跳过后真正更新累加器的次数。
    always @(posedge clk) begin
        if (rst) begin
            baseline_mac_count <= 0;
            actual_mac_count   <= 0;
        end
        else begin
            baseline_mac_count <= baseline_mac_count
                                + (uut.p00.a_valid_in && uut.p00.b_valid_in)
                                + (uut.p01.a_valid_in && uut.p01.b_valid_in)
                                + (uut.p10.a_valid_in && uut.p10.b_valid_in)
                                + (uut.p11.a_valid_in && uut.p11.b_valid_in);

            actual_mac_count <= actual_mac_count
                              + uut.p00.mac_en
                              + uut.p01.mac_en
                              + uut.p10.mac_en
                              + uut.p11.mac_en;
        end
    end
    // 同时检查四个输出矩阵元素和完成信号。
    task check_state;
        input [15:0] expected_c00;
        input [15:0] expected_c01;
        input [15:0] expected_c10;
        input [15:0] expected_c11;
        input expected_done;
        begin
            if (c00 !== expected_c00 || c01 !== expected_c01 ||
                c10 !== expected_c10 || c11 !== expected_c11 ||
                done !== expected_done) begin
                $display("FAIL time=%0t: C=[%0d %0d; %0d %0d], done=%b",
                         $time, c00, c01, c10, c11, done);
                $display("Expected: C=[%0d %0d; %0d %0d], done=%b",
                         expected_c00, expected_c01,
                         expected_c10, expected_c11, expected_done);
                failures = failures + 1;
            end else begin
                $display("PASS time=%0t: C=[%0d %0d; %0d %0d], done=%b",
                         $time, c00, c01, c10, c11, done);
            end
        end
    endtask

    // 在 done 拉高后检查一组运算累计的 MAC 次数。
    task check_mac_counts;
        input integer expected_baseline;
        input integer expected_actual;
        begin
            if (baseline_mac_count !== expected_baseline ||
                actual_mac_count !== expected_actual) begin
                $display("FAIL time=%0t: baseline_mac_count=%0d, actual_mac_count=%0d",
                         $time, baseline_mac_count, actual_mac_count);
                $display("Expected: baseline_mac_count=%0d, actual_mac_count=%0d",
                         expected_baseline, expected_actual);
                failures = failures + 1;
            end
            else begin
                $display("PASS time=%0t: baseline_mac_count=%0d, actual_mac_count=%0d",
                         $time, baseline_mac_count, actual_mac_count);
            end
        end
    endtask
    // 在下降沿改变输入，保证上升沿到来前输入稳定。
    task drive_inputs;
        input [7:0] next_a_row0;
        input [7:0] next_a_row1;
        input [7:0] next_b_col0;
        input [7:0] next_b_col1;
        input next_a_row0_valid;
        input next_a_row1_valid;
        input next_b_col0_valid;
        input next_b_col1_valid;
        begin
            @(negedge clk);
            start = 1'b0;
            a_row0_in = next_a_row0;
            a_row1_in = next_a_row1;
            b_col0_in = next_b_col0;
            b_col1_in = next_b_col1;
            a_row0_valid_in = next_a_row0_valid;
            a_row1_valid_in = next_a_row1_valid;
            b_col0_valid_in = next_b_col0_valid;
            b_col1_valid_in = next_b_col1_valid;
        end
    endtask

    // start 占用一个空拍；下一拍才开始送入第一组有效数据。
    task start_operation;
        begin
            @(negedge clk);
            start = 1'b1;
            a_row0_in = 8'd0;
            a_row1_in = 8'd0;
            b_col0_in = 8'd0;
            b_col1_in = 8'd0;
            a_row0_valid_in = 1'b0;
            a_row1_valid_in = 1'b0;
            b_col0_valid_in = 1'b0;
            b_col1_valid_in = 1'b0;
            @(posedge clk);
            #1;
            if (done !== 1'b0) begin
                $display("FAIL: done asserted on start at time %0t", $time);
                failures = failures + 1;
            end
        end
    endtask

    // A = [1 2; 3 4]，B = [5 6; 7 8]，期望 C = [19 22; 43 50]。
    task run_first_matrix;
        begin
            start_operation;
            drive_inputs(8'd1, 8'd0, 8'd5, 8'd0, 1'b1, 1'b0, 1'b1, 1'b0);
            @(posedge clk); #1;
            check_state(16'd5, 16'd0, 16'd0, 16'd0, 1'b0);
            drive_inputs(8'd2, 8'd3, 8'd7, 8'd6, 1'b1, 1'b1, 1'b1, 1'b1);
            @(posedge clk); #1;
            check_state(16'd19, 16'd6, 16'd15, 16'd0, 1'b0);
            drive_inputs(8'd0, 8'd4, 8'd0, 8'd8, 1'b0, 1'b1, 1'b0, 1'b1);
            @(posedge clk); #1;
            check_state(16'd19, 16'd22, 16'd43, 16'd18, 1'b0);
            drive_inputs(8'd0, 8'd0, 8'd0, 8'd0, 1'b0, 1'b0, 1'b0, 1'b0);
            @(posedge clk); #1;
            check_state(16'd19, 16'd22, 16'd43, 16'd50, 1'b1);
            check_mac_counts(8, 8);
            @(posedge clk); #1;
            check_state(16'd19, 16'd22, 16'd43, 16'd50, 1'b0);
        end
    endtask

    // A = [2 1; 0 3]，B = [1 4; 2 5]，期望 C = [4 13; 6 15]。
    // 第二组包含有效零值，用于验证零数据不会破坏 valid 传递。
    task run_second_matrix;
        begin
            start_operation;
            drive_inputs(8'd2, 8'd0, 8'd1, 8'd0, 1'b1, 1'b0, 1'b1, 1'b0);
            @(posedge clk); #1;
            check_state(16'd2, 16'd0, 16'd0, 16'd0, 1'b0);
            drive_inputs(8'd1, 8'd0, 8'd2, 8'd4, 1'b1, 1'b1, 1'b1, 1'b1);
            @(posedge clk); #1;
            check_state(16'd4, 16'd8, 16'd0, 16'd0, 1'b0);
            drive_inputs(8'd0, 8'd3, 8'd0, 8'd5, 1'b0, 1'b1, 1'b0, 1'b1);
            @(posedge clk); #1;
            check_state(16'd4, 16'd13, 16'd6, 16'd0, 1'b0);
            drive_inputs(8'd0, 8'd0, 8'd0, 8'd0, 1'b0, 1'b0, 1'b0, 1'b0);
            @(posedge clk); #1;
            check_state(16'd4, 16'd13, 16'd6, 16'd15, 1'b1);
            check_mac_counts(8, 6);
            @(posedge clk); #1;
            check_state(16'd4, 16'd13, 16'd6, 16'd15, 1'b0);
        end
    endtask

    initial begin
        rst = 1'b1;
        start = 1'b0;
        a_row0_in = 8'd0;
        a_row1_in = 8'd0;
        b_col0_in = 8'd0;
        b_col1_in = 8'd0;
        a_row0_valid_in = 1'b0;
        a_row1_valid_in = 1'b0;
        b_col0_valid_in = 1'b0;
        b_col1_valid_in = 1'b0;
        failures = 0;
        baseline_mac_count = 0;
        actual_mac_count = 0;
        repeat (2) @(posedge clk);
        #1;
        check_state(16'd0, 16'd0, 16'd0, 16'd0, 1'b0);
        rst = 1'b0;
        run_first_matrix;
        @(negedge clk);
        rst = 1'b1;
        start = 1'b0;
        @(posedge clk); #1;
        check_state(16'd0, 16'd0, 16'd0, 16'd0, 1'b0);
        rst = 1'b0;
        run_second_matrix;
        if (failures == 0)
            $display("TEST PASSED: two operations and done pulse verified");
        else
            $fatal(1, "TEST FAILED: %0d failure(s)", failures);
        $finish;
    end
endmodule
