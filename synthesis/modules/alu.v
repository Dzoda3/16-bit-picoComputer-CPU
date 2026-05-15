module alu #(
    parameter DATA_WIDTH = 16,
    parameter HIGH = DATA_WIDTH - 1
) (
    input [2:0]oc,
    input [HIGH:0]a,
    input [HIGH:0]b,
    output [HIGH:0]f
);

    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam MUL = 3'b010;
    localparam DIV = 3'b011;
    localparam NOT = 3'b100;
    localparam XOR = 3'b101;
    localparam OR = 3'b110;
    localparam AND  = 3'b111;

    integer i;  
    reg [HIGH:0]f_reg;
    
    assign f = f_reg;
    
    always @(*) begin
        case(oc)
            ADD: f_reg = a + b;
            SUB: f_reg = a - b;
            MUL: f_reg = a * b;
            DIV: f_reg = a / b;
            NOT: f_reg = ~a;
            XOR: f_reg = a ^ b;
            OR: f_reg = a | b;
            AND: f_reg = a & b;
        endcase
    end

endmodule