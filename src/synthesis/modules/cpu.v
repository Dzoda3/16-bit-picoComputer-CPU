module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH - 1:0]mem,
    input [DATA_WIDTH - 1:0]in,
    input control,
    output status,
    output we,
    output [ADDR_WIDTH - 1:0]addr,
    output [DATA_WIDTH - 1:0]data,
    output [DATA_WIDTH - 1:0]out,
    output [ADDR_WIDTH - 1:0]pc,
    output [ADDR_WIDTH - 1:0]sp
);

    localparam OP_KOD_VISI = 15;
    localparam OP_KOD_NIZI = 12;

    localparam PRVI_OPERAND_ADRESIRANJE = 11;
    localparam PRVI_OPERAND_VISI = 10;
    localparam PRVI_OPERAND_NIZI = 8;

    localparam DRUGI_OPERAND_ADRESIRANJE = 7;
    localparam DRUGI_OPERAND_VISI = 6;
    localparam DRUGI_OPERAND_NIZI = 4;

    localparam TRECI_OPERAND_ADRESIRANJE = 3;
    localparam TRECI_OPERAND_VISI = 2;
    localparam TRECI_OPERAND_NIZI = 0;


    localparam OP_MOVE = 4'b0000;
    localparam OP_ADD = 4'b0001;
    localparam OP_SUB = 4'b0010;
    localparam OP_MUL = 4'b0011;
    localparam OP_DIV = 4'b0100;
    localparam OP_IN = 4'b0111;
    localparam OP_OUT = 4'b1000;
    localparam OP_STOP = 4'b1111;


    localparam START = 0;
	localparam DOHVATI = 1;
	localparam DOHVATI_2 = 2;
	localparam DOHVATI_3 = 3;
	localparam PREPOZNAJ = 4;
	localparam IZVRSI = 5;
	localparam UPISI = 6;
	localparam ZAVRSI = 7;


    localparam DOHVATI_INSTRUKCIJU = 0;
    localparam DOHVATI_PRVI_OPERAND = 1;
    localparam DOHVATI_DRUGI_OPERAND = 2;
    localparam DOHVATI_TRECI_OPERAND = 3;
    localparam DOHVATI_PRVI_OPERAND_IND = 4;
	localparam DOHVATI_DRUGI_OPERAND_IND = 5;
	localparam DOHVATI_TRECI_OPERAND_IND = 6;
    localparam DOHVATI_INSTRUKCIJU_2 = 7;


    reg [4:0]faza_reg, faza_next;
    reg [4:0]stanje_reg, stanje_next;
    reg [DATA_WIDTH - 1:0]out_reg, out_next;
    reg we_reg, we_next;
    reg status_reg, status_next;
    
    assign out = out_reg;
    assign we = we_reg;
    assign pc = pc_out;
    assign sp = sp_out;
    assign addr = mar_out;
    assign data = mdr_out;
    assign status = status_reg;


    reg pc_cl;
    reg pc_ld;
    reg [5:0]pc_in;
    reg pc_inc;
    reg pc_dec;
    reg pc_sr;
    reg pc_ir;
    reg pc_sl;
    reg pc_il;
    wire [5:0]pc_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) PC (
        .clk(clk),
        .rst_n(rst_n),
        .cl(pc_cl),
        .ld(pc_ld),
        .in(pc_in),
        .inc(pc_inc),
        .dec(pc_dec),
        .sr(pc_sr),
        .ir(pc_ir),
        .sl(pc_sl),
        .il(pc_il),
        .out(pc_out)
    );


    reg sp_cl;
    reg sp_ld;
    reg [5:0]sp_in;
    reg sp_inc;
    reg sp_dec;
    reg sp_sr;
    reg sp_ir;
    reg sp_sl;
    reg sp_il;
    wire [5:0]sp_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) SP (
        .clk(clk),
        .rst_n(rst_n),
        .cl(sp_cl),
        .ld(sp_ld),
        .in(sp_in),
        .inc(sp_inc),
        .dec(sp_dec),
        .sr(sp_sr),
        .ir(sp_ir),
        .sl(sp_sl),
        .il(sp_il),
        .out(sp_out)
    );


    reg ir_cl;
    reg ir_ld;
    reg [31:0]ir_in;
    reg ir_inc;
    reg ir_dec;
    reg ir_sr;
    reg ir_ir;
    reg ir_sl;
    reg ir_il;
    wire [31:0]ir_out;

    register #(.DATA_WIDTH(2 * DATA_WIDTH)) IR (
        .clk(clk),
        .rst_n(rst_n),
        .cl(ir_cl),
        .ld(ir_ld),
        .in(ir_in),
        .inc(ir_inc),
        .dec(ir_dec),
        .sr(ir_sr),
        .ir(ir_ir),
        .sl(ir_sl),
        .il(ir_il),
        .out(ir_out)
    );


    reg pom_cl;
    reg pom_ld;
    reg [15:0]pom_in;
    reg pom_inc;
    reg pom_dec;
    reg pom_sr;
    reg pom_ir;
    reg pom_sl;
    reg pom_il;
    wire [15:0]pom_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) POM (
        .clk(clk),
        .rst_n(rst_n),
        .cl(pom_cl),
        .ld(pom_ld),
        .in(pom_in),
        .inc(pom_inc),
        .dec(pom_dec),
        .sr(pom_sr),
        .ir(pom_ir),
        .sl(pom_sl),
        .il(pom_il),
        .out(pom_out)
    );


    reg mar_cl;
    reg mar_ld;
    reg [5:0]mar_in;
    reg mar_inc;
    reg mar_dec;
    reg mar_sr;
    reg mar_ir;
    reg mar_sl;
    reg mar_il;
    wire [5:0]mar_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) MAR (
        .clk(clk),
        .rst_n(rst_n),
        .cl(mar_cl),
        .ld(mar_ld),
        .in(mar_in),
        .inc(mar_inc),
        .dec(mar_dec),
        .sr(mar_sr),
        .ir(mar_ir),
        .sl(mar_sl),
        .il(mar_il),
        .out(mar_out)
    );


    reg mdr_cl;
    reg mdr_ld;
    reg [15:0]mdr_in;
    reg mdr_inc;
    reg mdr_dec;
    reg mdr_sr;
    reg mdr_ir;
    reg mdr_sl;
    reg mdr_il;
    wire [15:0]mdr_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) MDR (
        .clk(clk),
        .rst_n(rst_n),
        .cl(mdr_cl),
        .ld(mdr_ld),
        .in(mdr_in),
        .inc(mdr_inc),
        .dec(mdr_dec),
        .sr(mdr_sr),
        .ir(mdr_ir),
        .sl(mdr_sl),
        .il(mdr_il),
        .out(mdr_out)
    );


    reg a_cl;
    reg a_ld;
    reg [15:0]a_in;
    reg a_inc;
    reg a_dec;
    reg a_sr;
    reg a_ir;
    reg a_sl;
    reg a_il;
    wire [15:0]a_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) A (
        .clk(clk),
        .rst_n(rst_n),
        .cl(a_cl),
        .ld(a_ld),
        .in(a_in),
        .inc(a_inc),
        .dec(a_dec),
        .sr(a_sr),
        .ir(a_ir),
        .sl(a_sl),
        .il(a_il),
        .out(a_out)
    );


    reg [2:0]alu_oc;
    reg [DATA_WIDTH - 1:0]alu_a;
    reg [DATA_WIDTH - 1:0]alu_b;
    wire [DATA_WIDTH - 1:0]alu_f;

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_MUL = 3'b010;
    localparam ALU_DIV = 3'b011;
    localparam ALU_NOT = 3'b100;
    localparam ALU_XOR = 3'b101;
    localparam ALU_OR = 3'b110;
    localparam ALU_AND = 3'b111;

    alu #(.DATA_WIDTH(DATA_WIDTH)) ALU (
        .oc(alu_oc),
        .a(alu_a),
        .b(alu_b),
        .f(alu_f)
    );


    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            faza_reg <= START;
            stanje_reg <= 0;
            out_reg <= {DATA_WIDTH{1'b0}};
            we_reg <= 1'b0;
            status_reg <= 1'b0;
        end else begin
            faza_reg <= faza_next;
            stanje_reg <= stanje_next;
            out_reg <= out_next;
            we_reg <= we_next;
            status_reg = status_next;
        end
    end

    always @(*) begin
        pc_in = pc; pc_cl = 1'b0; pc_ld = 1'b0; pc_inc = 1'b0; pc_dec = 1'b0; pc_sr = 1'b0; pc_ir = 1'b0; pc_sl = 1'b0; pc_il = 1'b0;
        sp_in = sp; sp_cl = 1'b0; sp_ld = 1'b0; sp_inc = 1'b0; sp_dec = 1'b0; sp_sr = 1'b0; sp_ir = 1'b0; sp_sl = 1'b0; sp_il = 1'b0;
        ir_in = ir_out; ir_cl = 1'b0; ir_ld = 1'b0; ir_inc = 1'b0; ir_dec = 1'b0; ir_sr = 1'b0; ir_ir = 1'b0; ir_sl = 1'b0; ir_il = 1'b0;
        mar_in = mar_out; mar_cl = 1'b0; mar_ld = 1'b0; mar_inc = 1'b0; mar_dec = 1'b0; mar_sr = 1'b0; mar_ir = 1'b0; mar_sl = 1'b0; mar_il = 1'b0;
        mdr_in = mem; mdr_cl = 1'b0; mdr_ld = 1'b0; mdr_inc = 1'b0; mdr_dec = 1'b0; mdr_sr = 1'b0; mdr_ir = 1'b0; mdr_sl = 1'b0; mdr_il = 1'b0;
        a_in = a_out; a_cl = 1'b0; a_ld = 1'b0; a_inc = 1'b0; a_dec = 1'b0; a_sr = 1'b0; a_ir = 1'b0; a_sl = 1'b0; a_il = 1'b0;
        alu_oc = 3'b000; alu_a = {DATA_WIDTH{1'b0}}; alu_b = {DATA_WIDTH{1'b0}}; 
        
        out_next = out_reg;
        faza_next = faza_reg;
        stanje_next = stanje_reg;
        we_next = 1'b0;
        status_next = 1'b0;

        case(faza_reg)
            START: begin
                pc_ld = 1'b1;
                pc_in = {ADDR_WIDTH{1'b0}} + 8;
                sp_ld = 1'b1;
                sp_in = {ADDR_WIDTH{1'b1}};
                faza_next = DOHVATI;
                stanje_next = DOHVATI_INSTRUKCIJU;
            end 

            DOHVATI: begin
                case(stanje_reg)
                    DOHVATI_INSTRUKCIJU,
                    DOHVATI_INSTRUKCIJU_2: begin
                        mar_ld = 1'b1;
                        mar_in = pc;
                        pc_inc = 1'b1;
                    end

                    DOHVATI_PRVI_OPERAND: begin
                        mar_ld = 1'b1;
                        mar_in = {{3{1'b0}}, ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI]};
                    end

                    DOHVATI_DRUGI_OPERAND: begin
                        mar_ld = 1'b1;
                        mar_in = {{3{1'b0}}, ir_out[DRUGI_OPERAND_VISI:DRUGI_OPERAND_NIZI]};
                    end

                    DOHVATI_TRECI_OPERAND: begin
                        mar_ld = 1'b1;
                        mar_in = {{3{1'b0}}, ir_out[TRECI_OPERAND_VISI:TRECI_OPERAND_NIZI]};
                    end
                    
                    DOHVATI_PRVI_OPERAND_IND,
                    DOHVATI_DRUGI_OPERAND_IND,
                    DOHVATI_TRECI_OPERAND_IND: begin
                        mar_ld = 1'b1;
                        mar_in = mdr_out[ADDR_WIDTH - 1:0];
                    end
                endcase

                faza_next = DOHVATI_2;
            end

            DOHVATI_2: begin
                we_next = 1'b0;
                faza_next = DOHVATI_3;
            end
					 
            DOHVATI_3: begin
                mdr_ld = 1'b1;
                faza_next = PREPOZNAJ;
            end

            PREPOZNAJ: begin
                case(stanje_reg)
                    DOHVATI_INSTRUKCIJU: begin
                        ir_ld = 1'b1;
                        ir_in[15:0] = mdr_out;

                        case(mdr_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_MOVE: begin
                                if(mdr_out[TRECI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    stanje_next = DOHVATI_INSTRUKCIJU_2;
                                    faza_next = DOHVATI;
                                end else if(mdr_out[PRVI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND;
                                end else begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_DRUGI_OPERAND;
                                end

                                if(PRVI_OPERAND_ADRESIRANJE == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_INSTRUKCIJU_2;
                                end
                            end

                            OP_ADD,
                            OP_SUB,
                            OP_MUL: begin
                                if(mdr_out[PRVI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND;
                                end else begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_DRUGI_OPERAND;
                                end
                            end

                            OP_IN: begin
                                if(mdr_out[PRVI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND;
                                end else begin
                                    faza_next = IZVRSI;
                                end
                            end

                            OP_DIV: begin
                                faza_next = START;
                            end

                            OP_OUT,
                            OP_STOP: begin
                                faza_next = DOHVATI;
                                stanje_next = DOHVATI_PRVI_OPERAND;
                            end
                        endcase
                    end

                    DOHVATI_INSTRUKCIJU_2: begin
                        pom_ld = 1'b1;
                        pom_in = mdr_out;
                        
                        case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_MOVE: begin
                                if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND;
                                end else begin
                                    faza_next = IZVRSI;
                                end

                                if(PRVI_OPERAND_ADRESIRANJE == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND;
                                end
                            end
                        endcase
                    end

                    DOHVATI_PRVI_OPERAND: begin
                        case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_MOVE,
                            OP_ADD,
                            OP_SUB,
                            OP_MUL: begin
                                ir_ld = 1'b1;
                                ir_in = {mdr_out, ir_out[15:0]};
                                faza_next = DOHVATI;
                                stanje_next = DOHVATI_DRUGI_OPERAND;
                            end
                            
                            OP_IN: begin
                                ir_ld = 1'b1;
                                ir_in = {mdr_out, ir_out[15:0]};
                                faza_next = IZVRSI;
                            end

                            OP_OUT: begin
                                if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND_IND;
                                end else begin
                                    ir_ld = 1'b1;
                                    ir_in = {mdr_out, ir_out[15:0]};
                                    faza_next = IZVRSI;
                                end
                            end

                            OP_STOP: begin
                                if((ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b1) && (ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI] != 3'b000)) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_PRVI_OPERAND_IND;
                                end else if((ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b0) && (ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI] != 3'b000)) begin
                                    ir_ld = 1'b1;
                                    ir_in = {mdr_out, ir_out[15:0]};
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_DRUGI_OPERAND;
                                end
                            end
                        endcase
                    end

                    DOHVATI_DRUGI_OPERAND: begin
                        case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_MOVE: begin
                                if(ir_out[DRUGI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_DRUGI_OPERAND_IND;
                                end else begin
                                    a_ld = 1'b1;
                                    a_in = mdr_out;
                                    faza_next = IZVRSI;
                                end
                            end

                            OP_ADD,
                            OP_SUB,
                            OP_MUL: begin
                                if(ir_out[DRUGI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_DRUGI_OPERAND_IND;
                                end else begin
                                    a_ld = 1'b1;
                                    a_in = mdr_out;
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_TRECI_OPERAND;
                                end
                            end

                            OP_STOP: begin
                                if((ir_out[DRUGI_OPERAND_ADRESIRANJE] == 1'b1) && (ir_out[DRUGI_OPERAND_VISI:DRUGI_OPERAND_NIZI] != 3'b000)) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_DRUGI_OPERAND_IND;
                                end else if((ir_out[DRUGI_OPERAND_ADRESIRANJE] == 1'b0) && (ir_out[DRUGI_OPERAND_VISI:DRUGI_OPERAND_NIZI] != 3'b000)) begin
                                    ir_ld = 1'b1;
                                    ir_in = {mdr_out, ir_out[15:0]};
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_TRECI_OPERAND;
                                end
                            end
                        endcase
                    end

                    DOHVATI_TRECI_OPERAND: begin
                        case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_MOVE,
                            OP_ADD,
                            OP_SUB,
                            OP_MUL: begin
                                if(ir_out[TRECI_OPERAND_ADRESIRANJE] == 1'b1) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_TRECI_OPERAND_IND;
                                end else begin
                                    faza_next = IZVRSI;
                                end
                            end

                            OP_STOP: begin
                                if((ir_out[TRECI_OPERAND_ADRESIRANJE] == 1'b1) && (ir_out[TRECI_OPERAND_VISI:TRECI_OPERAND_NIZI] != 3'b000)) begin
                                    faza_next = DOHVATI;
                                    stanje_next = DOHVATI_TRECI_OPERAND_IND;
                                end else if((ir_out[TRECI_OPERAND_ADRESIRANJE] == 1'b0) && (ir_out[TRECI_OPERAND_VISI:TRECI_OPERAND_NIZI] != 3'b000)) begin
                                    faza_next = IZVRSI;
                                end
                            end
                        endcase
                    end

                    DOHVATI_PRVI_OPERAND_IND: begin
                        case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_OUT: begin
                                ir_ld = 1'b1;
                                ir_in = {mdr_out, ir_out[15:0]};
                                faza_next = IZVRSI;    
                            end 

                            OP_STOP: begin
                                ir_ld = 1'b1;
                                ir_in = {mdr_out, ir_out[15:0]};
                                faza_next = DOHVATI;
                                stanje_next = DOHVATI_DRUGI_OPERAND;  
                            end 
                        endcase
                    end

                    DOHVATI_DRUGI_OPERAND_IND: begin
                        a_ld = 1'b1;
                        a_in = mdr_out;
                        faza_next = DOHVATI;
                        stanje_next = DOHVATI_TRECI_OPERAND;
                    end

                    DOHVATI_TRECI_OPERAND_IND: begin
                        case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                            OP_MOVE,
                            OP_ADD,
                            OP_SUB,
                            OP_MUL,
                            OP_STOP: begin
                                faza_next = IZVRSI;
                            end
                        endcase
                    end
                endcase
            end
            

            IZVRSI: begin
                case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                    OP_MOVE: begin
                        mdr_ld = 1'b1;
                        if(ir_out[TRECI_OPERAND_ADRESIRANJE] == 1'b1) begin
                            mdr_in = pom_out[DATA_WIDTH - 1:0];
                        end else begin
                            mdr_in = a_out;
                        end
                        
                        mar_ld = 1'b1;
                        if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b0) begin
                            mar_in = {{(ADDR_WIDTH - 3){1'b0}}, ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI]};
                        end else begin
                            mar_in = ir_out[(2 * DATA_WIDTH - 1):DATA_WIDTH];
                        end

                        faza_next = UPISI;

                        if(PRVI_OPERAND_ADRESIRANJE == 1'b1) begin
                            if(ir_out[31:16] == a_out) begin
                                pc_ld = 1'b1;
                                pc_in = pom_out;
                            end

                            faza_next = DOHVATI;
                            stanje_next = DOHVATI_INSTRUKCIJU;
                        end
                    end

                    OP_ADD: begin
                        alu_oc = ALU_ADD;
                        alu_a = a_out;
                        alu_b = mdr_out;
                        mdr_ld = 1'b1;
                        mdr_in = alu_f;
                        
                        mar_ld = 1'b1;
                        if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b0) begin
                            mar_in = {{(ADDR_WIDTH - 3){1'b0}}, ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI]};                            
                        end else begin
                            mar_in = ir_out[(2 * DATA_WIDTH - 1):DATA_WIDTH];
                        end

                        faza_next = UPISI;
                    end

                    OP_SUB: begin
                        alu_oc = ALU_SUB;
                        alu_a = a_out;
                        alu_b = mdr_out;
                        mdr_ld = 1'b1;
                        mdr_in = alu_f;
                        
                        mar_ld = 1'b1;
                        if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b0) begin
                            mar_in = {{(ADDR_WIDTH - 3){1'b0}}, ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI]};                            
                        end else begin
                            mar_in = ir_out[(2 * DATA_WIDTH - 1):DATA_WIDTH];
                        end

                        faza_next = UPISI;
                    end

                    OP_MUL: begin
                        alu_oc = ALU_MUL;
                        alu_a = a_out;
                        alu_b = mdr_out;
                        mdr_ld = 1'b1;
                        mdr_in = alu_f;
                        
                        mar_ld = 1'b1;
                        if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b0) begin
                            mar_in = {{(ADDR_WIDTH - 3){1'b0}}, ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI]};                            
                        end else begin
                            mar_in = ir_out[(2 * DATA_WIDTH - 1):DATA_WIDTH];
                        end

                        faza_next = UPISI;
                    end

                    OP_IN: begin
                        if(control == 1'b1) begin
                            mdr_ld = 1'b1;
                            mdr_in = in;

                            mar_ld = 1'b1;
                            if(ir_out[PRVI_OPERAND_ADRESIRANJE] == 1'b0) begin
                                mar_in = {{(ADDR_WIDTH - 3){1'b0}}, ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI]};                            
                            end else begin
                                mar_in = ir_out[(2 * DATA_WIDTH - 1):DATA_WIDTH];
                            end
                            
                            faza_next = UPISI; 
                        end else begin
                            status_next = 1'b1;
                            faza_next = IZVRSI;
                        end
                    end

                    OP_OUT: begin
                        out_next = ir_out[(2 * DATA_WIDTH - 1):16];
                        faza_next = DOHVATI;
                        stanje_next = DOHVATI_INSTRUKCIJU;
                    end

                    OP_STOP: begin
                        if(ir_out[PRVI_OPERAND_VISI:PRVI_OPERAND_NIZI] != 3'b000) begin
                            out_next = ir_out[(2 * DATA_WIDTH - 1):16];
                        end
                        faza_next = UPISI;
                    end
                endcase
            end


            UPISI: begin
                case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                    OP_MOVE,
                    OP_ADD,
                    OP_SUB,
                    OP_MUL,
                    OP_IN: begin
                        we_next = 1'b1;
                        faza_next = DOHVATI;
                        stanje_next = DOHVATI_INSTRUKCIJU;
                    end

                    OP_STOP: begin
                        if(ir_out[DRUGI_OPERAND_VISI:DRUGI_OPERAND_NIZI] != 3'b000) begin
                            out_next = a_out;
                        end
                        faza_next = ZAVRSI;
                    end
                endcase
            end


            ZAVRSI: begin
                case(ir_out[OP_KOD_VISI:OP_KOD_NIZI])
                    OP_STOP: begin
                        if(ir_out[TRECI_OPERAND_VISI:TRECI_OPERAND_NIZI] != 3'b000) begin
                            out_next = mdr_out;
                        end
                        faza_next = ZAVRSI;
                    end
                endcase
            end
        endcase
    end
endmodule