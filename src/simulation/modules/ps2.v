module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0]code
);

    localparam SPREMAN = 0;
    localparam SLANJE = 1;
    localparam ZAVRSI = 2;

    reg brojac_reg, brojac_next = 1'b0;
    reg parnost_reg, parnost_next = 1'b0;
    reg [1:0]stanje_reg, stanje_next = 2'b0;
    reg [3:0]n_reg, n_next = 4'h0;
    reg [8:0]podatak_reg, podatak_next = 9'h000;
    reg [15:0]kod_reg, kod_next = 16'h0000;
    reg [15:0]displej_kod_reg, displej_kod_next = 16'h0000;
    
    assign code = displej_kod_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            brojac_reg <= 1'b0;
            parnost_reg <= 1'b0;
            stanje_reg <= 2'b00;
            n_reg <= 4'h0;
            podatak_reg <= 9'h000;
            kod_reg <= 16'h0000;
            displej_kod_reg <= 16'h0000;
        end else begin
            brojac_reg <= brojac_next;
            parnost_reg <= parnost_next;
            stanje_reg <= stanje_next;
            n_reg <= n_next;
            podatak_reg <= podatak_next;
            kod_reg <= kod_next;
            displej_kod_reg <= displej_kod_next;
        end
    end

    always @(negedge ps2_clk) begin
        brojac_next = brojac_reg;
        parnost_next = parnost_reg;
        stanje_next = stanje_reg;
        n_next = n_reg;
        podatak_next = podatak_reg;
        kod_next = kod_reg;
        displej_kod_next = displej_kod_reg;
        
        case(stanje_reg)
            SPREMAN: begin
                if(ps2_data == 1'b0) begin
                    n_next <= 4'h9;
                    podatak_next = 9'h000;
                    stanje_next = SLANJE;
                    
                    if(podatak_reg[7:0] != 8'he0 && podatak_reg[7:0] != 8'hf0) begin
                        kod_next = 16'h0000;
                    end
                end
            end

            SLANJE: begin
                if(n_reg == 4'h9) begin
                    parnost_next = ps2_data;
                end else begin
                    parnost_next = parnost_reg ^ ps2_data;
                end

                podatak_next = {ps2_data, podatak_reg[8:1]};

                if(n_reg == 4'h1) begin
                    stanje_next = ZAVRSI;
                end else begin
                    n_next = n_reg - 1'b1;
                end
            end

            ZAVRSI: begin
                if(ps2_data == 1'b1) begin
                    if(parnost_reg) begin
                        kod_next = (kod_reg << 8) | podatak_reg[7:0];

                        if(brojac_reg == 0 || podatak_reg[7:0] == 8'he0 || podatak_reg[7:0] == 8'hf0) begin
                            brojac_next = 1'b1;
                        end else begin
                            displej_kod_next = kod_next;
                            brojac_next = 1'b0;
                        end
                    end else begin
                        displej_kod_next = 16'hFFFF;
                    end

                    stanje_next = SPREMAN;
                end
            end
        endcase
    end

endmodule