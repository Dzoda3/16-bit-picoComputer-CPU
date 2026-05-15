module color_codes (
    input [5:0]num,
    output reg [23:0]code
);

    reg[11:0] ones, tens;

    always @(*) begin
        case(num / 10)
            4'd0: tens = 12'h000; 
            4'd1: tens = 12'hF00; 
            4'd2: tens = 12'hF80; 
            4'd3: tens = 12'hFF0; 
            4'd4: tens = 12'h0F0; 
            4'd5: tens = 12'h0FF; 
            4'd6: tens = 12'h08F; 
            4'd7: tens = 12'h00F; 
            4'd8: tens = 12'hF0F; 
            4'd9: tens = 12'hFFF; 
            default: tens = 12'h000;
        endcase

        case(num % 10)
            4'd0: ones = 12'h000; 
            4'd1: ones = 12'hF00; 
            4'd2: ones = 12'hF80; 
            4'd3: ones = 12'hFF0; 
            4'd4: ones = 12'h0F0; 
            4'd5: ones = 12'h0FF; 
            4'd6: ones = 12'h08F; 
            4'd7: ones = 12'h00F; 
            4'd8: ones = 12'hF0F; 
            4'd9: ones = 12'hFFF; 
            default: ones = 12'h000;
        endcase

        code[23:12] = tens;
        code[11:0] = ones;
    end
    
endmodule