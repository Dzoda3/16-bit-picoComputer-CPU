module alu_stari (
    input [2:0] oc,
    input [3:0]a,
    input [3:0]b,
    output reg[3:0]f
);

    always @(*) begin
        case(oc)
            3'b000 : begin
                f[0] = a[0] + b[0];
                f[1] = a[1] + b[1]; 
                f[2] = a[2] + b[2];
                f[3] = a[3] + b[3];
            end
            3'b001 : begin
                f[0] = a[0] - b[0];
                f[1] = a[1] - b[1]; 
                f[2] = a[2] - b[2];
                f[3] = a[3] - b[3];
            end
            3'b010 : f = a * b;
            3'b011 : f = a / b;
            3'b100 : f = ~a;
            3'b101 : f = a ^ b;
            3'b110 : f = a | b;
            3'b111 : f = a & b;
        endcase
    end
    
endmodule