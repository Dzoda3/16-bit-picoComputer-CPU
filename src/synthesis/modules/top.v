module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [2:0]btn,
    input [8:0]sw,
    output [9:0]led,
    output [27:0]hex
);
   
    wire usporen_clk;
    clk_div #(.DIVISOR(DIVISOR)) CLK_DIV (
        .clk(clk), 
        .rst_n(rst_n), 
        .out(usporen_clk)
    );

	 
	wire we;
    wire [ADDR_WIDTH - 1:0]addr;
    wire [DATA_WIDTH - 1:0]data;
    wire [DATA_WIDTH - 1:0]mem;
    memory #(.FILE_NAME(FILE_NAME), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) MEMORY (
        .clk(usporen_clk), 
        .we(we), 
        .addr(addr), 
        .data(data), 
        .out(mem)
    );


    wire [ADDR_WIDTH - 1:0]pc, sp;
    wire [DATA_WIDTH - 1:0]out;
    assign led[4:0] = out[4:0];
    cpu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) CPU (
        .clk(usporen_clk), 
        .rst_n(rst_n), 
        .mem(mem), 
        .in(sw[3:0]),
        .control(sw[5]),
        .we(we), 
        .addr(addr), 
        .data(data), 
        .out(out), 
        .pc(pc), 
        .sp(sp)
    );
    

    wire [3:0]ones_bcd1, tens_bcd1;
    bcd BCD1 (
        .in(pc[5:0]), 
        .ones(ones_bcd1), 
        .tens(tens_bcd1)
    );

    ssd SSD1 (
        .in(ones_bcd1), 
        .out(hex[6:0])
    );

    ssd SSD2 (
        .in(tens_bcd1), 
        .out(hex[13:7])
    );
    
    wire [3:0]ones_bcd2, tens_bcd2;
    bcd BCD2 (
        .in(sp[5:0]), 
        .ones(ones_bcd2), 
        .tens(tens_bcd2)
    );

    ssd SSD3 (
        .in(ones_bcd2), 
        .out(hex[20:14])
    );

    ssd SSD4 (
        .in(tens_bcd2), 
        .out(hex[27:21])
    );
	 
endmodule