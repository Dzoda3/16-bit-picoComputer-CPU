module scan_codes (
    input clk,
    input rst_n,
    input [15:0]code,
    input status,
    output control,
    output [3:0]num
);

    assign control = control_reg;
    assign num = num_reg;

    reg [3:0]num_reg, num_next;
    reg control_reg, control_next;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            num_reg <= 4'h0;
            control_reg <= 1'b0;
        end else begin
            num_reg <= num_next;
            control_reg <= control_next;
        end
    end

    always @(*) begin
        num_next = num_reg;
        control_next = 1'b0;

        if(status) begin
            case(code)
                16'hF070: begin 
                    num_next = 4'd0; 
                    control_next = 1'b1; 
                end

                16'hF069: begin 
                    num_next = 4'd1; 
                    control_next = 1'b1; 
                end

                16'hF072: begin 
                    num_next = 4'd2; 
                    control_next = 1'b1; 
                end
                
                16'hF07A: begin 
                    num_next = 4'd3; 
                    control_next = 1'b1; 
                end
                
                16'hF06B: begin 
                    num_next = 4'd4; 
                    control_next = 1'b1; 
                end
                
                16'hF073: begin 
                    num_next = 4'd5; 
                    control_next = 1'b1; 
                end
                
                16'hF074: begin 
                    num_next = 4'd6; 
                    control_next = 1'b1; 
                end
                
                16'hF06C: begin 
                    num_next = 4'd7; 
                    control_next = 1'b1; 
                end
                
                16'hF075: begin 
                    num_next = 4'd8; 
                    control_next = 1'b1; 
                end
                
                16'hF07D: begin 
                    num_next = 4'd9; 
                    control_next = 1'b1; 
                end
                
                default: control_next = 1'b0;
            endcase
        end

        if(!status) control_next = 1'b0;
    end
    
endmodule