module bcd (
    input [5:0]in,
    output [3:0]ones,
    output [3:0]tens
);
    
    reg [3:0]ones_reg, tens_reg;
    assign ones = ones_reg;
    assign tens = tens_reg;

    always @(*) begin
        tens_reg = in / 10;
        ones_reg = in % 10;
    end

endmodule