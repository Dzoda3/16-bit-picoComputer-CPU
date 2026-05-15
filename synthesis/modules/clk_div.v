module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output out
);

    integer brojac_reg, brojac_next;
    reg out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            brojac_reg <= 0;
            out_reg <= 1'b0;
        end else begin
            brojac_reg <= brojac_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        brojac_next = brojac_reg + 1;
        out_next = out_reg;

        if(brojac_reg == DIVISOR) begin
            out_next = ~out_reg;
            brojac_next = 0;
        end 
    end
    
endmodule