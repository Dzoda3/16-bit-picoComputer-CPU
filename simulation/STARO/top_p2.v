module top_p2;

    reg dut_clk;
    reg dut_we;
    reg [5:0]dut_addr;
    reg [7:0]dut_data;
    wire [7:0]dut_out;

    memorija dut(dut_clk, dut_we, dut_addr, dut_data, dut_out);

    initial begin
        dut_clk = 1'b0;
        forever #5 dut_clk = ~dut_clk;
    end

    initial begin
        dut_we = 1'b1;
        dut_data = $urandom % 256;
        dut_addr = 6'b000000;

        #7;

        repeat(64) begin
            #10;
            dut_data = $urandom % 256;
            dut_addr = dut_addr + 1;
        end

        dut_we = 1'b0;
        dut_addr = 1'b0;
        repeat(100) begin
            #10;
            dut_addr = $urandom % 64;
        end
        $finish;
    end

    always @(dut_out) begin
        $display("time = %0d, dut_we = %b, dut_addr = %b, dut_data = %b, dut_out = %b", $time, dut_we, dut_addr, dut_data, dut_out);
    end

endmodule