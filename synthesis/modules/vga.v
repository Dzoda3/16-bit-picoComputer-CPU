module vga (
    input clk,
    input rst_n,
    input [23:0]code,
    output hsync,
    output vsync,
    output [3:0]red,
    output [3:0]green,
    output [3:0]blue
);
    
    assign hsync = ~((h >= H_SYNC_START) && (h < H_SYNC_END));
    assign vsync = ~((v >= V_SYNC_START) && (v < V_SYNC_END));
    assign red = visible ? (left ? code[23:20] : code[11:8]) : 0;
    assign green = visible ? (left ? code[19:16] : code[7:4]) : 0;
    assign blue = visible ? (left ? code[15:12] : code[3:0]) : 0;

    reg [10:0]h;
    reg [9:0]v;
    reg visible, left;  

    localparam H_DISP = 800;
    localparam H_FP = 56;
    localparam H_SP = 120;
    localparam H_BP = 64;
    localparam H = H_DISP + H_FP + H_SP + H_BP;
    localparam H_SYNC_START = H_DISP + H_FP;
    localparam H_SYNC_END = H_SYNC_START + H_SP;

    localparam V_DISP = 600;
    localparam V_FP = 37;
    localparam V_SP = 6;
    localparam V_BP = 23;
    localparam V = V_DISP + V_FP + V_SP + V_BP;
    localparam V_SYNC_START = V_DISP + V_FP;
    localparam V_SYNC_END = V_SYNC_START + V_SP;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            h <= 0;
            v <= 0;
        end else begin
            if(h == H - 1) begin
                h <= 0;
                if(v == V - 1)
                    v <= 0;
                else
                    v <= v + 1;
            end else begin
                h <= h + 1;
            end
        end

        visible = h < H_DISP && v < V_DISP;
        left = h < H_DISP / 2;
    end

endmodule