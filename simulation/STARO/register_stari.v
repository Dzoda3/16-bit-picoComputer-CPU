module register_stari (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [3:0]in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [3:0]out
);
    
    reg [3:0]out_reg, out_next;
    integer i;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            out_reg <= 4'h0;
        else
            out_reg <= out_next;
    end

    always @(*) begin
        out_next = out_reg;

        if(cl) out_next = 4'h0;
        else if(ld) out_next = in;
        else if(inc) out_next = out_reg + 1;
        else if(dec) out_next = out_reg - 1;

        else if(sr) begin
            for(i = 0; i < 3; i = i + 1) begin
                out_next[i] = out_reg[i + 1];
            end
            out_next[3] = ir;
        end 

        else if(sl) begin
            for(i = 3; i > 0; i = i - 1) begin
                out_next[i] = out_reg[i - 1];
            end
            out_next[0] = il;
        end
    end

endmodule