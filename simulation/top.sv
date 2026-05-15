`include "uvm_macros.svh"
import uvm_pkg::*;


class ps2_item extends uvm_sequence_item;

    rand bit ps2_clk;
    rand bit ps2_data;
    bit [15:0]code;
	
	`uvm_object_utils_begin(ps2_item)
		`uvm_field_int(ps2_clk, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(ps2_data, UVM_DEFAULT | UVM_BIN)
		`uvm_field_int(code, UVM_DEFAULT | UVM_HEX)
	`uvm_object_utils_end
	
	function new(string name = "ps2_item");
		super.new(name);
	endfunction
	
	virtual function string my_print();
		return $sformatf(
			"ps2_clk = %1b ps2_data = %1b code = %4h",
			ps2_clk, ps2_data, code
		);
	endfunction

endclass


class generator extends uvm_sequence;

	`uvm_object_utils(generator)
	
	function new(string name = "generator");
		super.new(name);
	endfunction
	
	int num = 1000;
	
	virtual task body();
		for (int i = 0; i < num; i++) begin
			ps2_item item = ps2_item::type_id::create("item");
			start_item(item);
			item.randomize();
			`uvm_info("Generator", $sformatf("Item %0d/%0d created", i + 1, num), UVM_LOW)
			item.print();
			finish_item(item);
		end
	endtask
	
endclass


class driver extends uvm_driver #(ps2_item);
	
	`uvm_component_utils(driver)
	
	function new(string name = "driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual ps2_if vif;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Driver", "No interface.")
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			ps2_item item;
			seq_item_port.get_next_item(item);
			`uvm_info("Driver", $sformatf("%s", item.my_print()), UVM_LOW)
			vif.ps2_clk <= item.ps2_clk;
			vif.ps2_data <= item.ps2_data;
			
			@(posedge vif.clk);
			seq_item_port.item_done();
		end
	endtask
	
endclass


class monitor extends uvm_monitor;
	
	`uvm_component_utils(monitor)
	
	function new(string name = "monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual ps2_if vif;
	uvm_analysis_port #(ps2_item) mon_analysis_port;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Monitor", "No interface.")
		mon_analysis_port = new("mon_analysis_port", this);
	endfunction
	
	virtual task run_phase(uvm_phase phase);	
		super.run_phase(phase);
		@(posedge vif.clk);
		forever begin
			ps2_item item = ps2_item::type_id::create("item");
			@(posedge vif.clk);
            item.ps2_clk = vif.ps2_clk;
            item.ps2_data = vif.ps2_data;
            item.code = vif.code;

			`uvm_info("Monitor", $sformatf("%s", item.my_print()), UVM_LOW)
			mon_analysis_port.write(item);
		end
	endtask
	
endclass


class agent extends uvm_agent;
	
	`uvm_component_utils(agent)
	
	function new(string name = "agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	driver d0;
	monitor m0;
	uvm_sequencer #(ps2_item) s0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		d0 = driver::type_id::create("d0", this);
		m0 = monitor::type_id::create("m0", this);
		s0 = uvm_sequencer#(ps2_item)::type_id::create("s0", this);
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		d0.seq_item_port.connect(s0.seq_item_export);
	endfunction
	
endclass


class scoreboard extends uvm_scoreboard;
	
	`uvm_component_utils(scoreboard)
	
	function new(string name = "scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	uvm_analysis_imp #(ps2_item, scoreboard) mon_analysis_imp;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon_analysis_imp = new("mon_analysis_imp", this);
	endfunction
	

	typedef enum bit[1:0] {SPREMAN, SLANJE, ZAVRSI} stanja;
    stanja stanje;

	reg brojac = 1'b0;
	reg parnost = 1'b0;
	reg clk = 1'b0;
	reg [3:0]n = 4'd0;
    reg [8:0]podatak = 9'd0;
    reg [15:0]kod = 16'd0;
	reg [15:0]kod_provera = 16'd0;
	
	virtual function write(ps2_item item);
		if(kod_provera == item.code) begin
			`uvm_info("Scoreboard", $sformatf("PASS! expected = %16b, got = %16b", kod_provera, item.code), UVM_LOW)
		end
		else begin
			`uvm_error("Scoreboard", $sformatf("FAIL! expected = %16b, got = %16b", kod_provera, item.code))
		end

		if(clk == 1'b0 && item.ps2_clk == 1'b0) begin
			case(stanje)
				SPREMAN : begin
					if(item.ps2_data == 0) begin
						n = 4'd9;
						podatak  = 9'd0;
						stanje = SLANJE;
						if(podatak[7:0] != 8'he0 && podatak[7:0] != 8'hf0) begin
							kod = 16'd0;
						end
					end
				end

				SLANJE : begin
					if (n == 4'd9) begin
                        parnost = item.ps2_data;
					end	else begin
						parnost = parnost ^ item.ps2_data;
					end

					podatak = {item.ps2_data, podatak[8:1]};

					if (n == 4'd1) begin
						stanje = ZAVRSI;
					end
					else begin
						n = n - 1'b1;
					end
				end

				ZAVRSI : begin	
					if (item.ps2_data == 1) begin
						if(parnost) begin
							kod = (kod << 8) | podatak[7:0];

							if(brojac == 0 || podatak[7:0] == 8'he0 || podatak[7:0] == 8'hf0) begin
								brojac = 1'b1;
							end
							else begin
								kod_provera = kod;
								brojac = 1'b0;
							end
						end else begin
							kod_provera = 16'hFFFF;
						end
					stanje = SPREMAN;
					end
				end
			endcase
		end
		clk = item.ps2_clk;
	endfunction	
endclass


class env extends uvm_env;
	
	`uvm_component_utils(env)
	
	function new(string name = "env", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	agent a0;
	scoreboard sb0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		a0 = agent::type_id::create("a0", this);
		sb0 = scoreboard::type_id::create("sb0", this);
	endfunction
	
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		a0.m0.mon_analysis_port.connect(sb0.mon_analysis_imp);
	endfunction
	
endclass


class test extends uvm_test;

	`uvm_component_utils(test)
	
	function new(string name = "test", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual ps2_if vif;

	env e0;
	generator g0;
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ps2_if)::get(this, "", "ps2_vif", vif))
			`uvm_fatal("Test", "No interface.")
		e0 = env::type_id::create("e0", this);
		g0 = generator::type_id::create("g0");
	endfunction
	
	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		
		vif.rst_n <= 0;
		#20 vif.rst_n <= 1;
		
		g0.start(e0.a0.s0);
		phase.drop_objection(this);
	endtask

endclass


interface ps2_if (
    input bit clk
);

    logic ps2_clk;
    logic ps2_data;
    logic rst_n;
    logic [15:0]code;

endinterface


module top;

	reg clk;
	
	ps2_if dut_if (
		.clk(clk)
	);
	
	ps2 dut (
		.clk(clk),
		.rst_n(dut_if.rst_n),
		.ps2_clk(dut_if.ps2_clk),
		.ps2_data(dut_if.ps2_data),
		.code(dut_if.code)
	);

	initial begin
		clk = 0;
		forever begin
			#10 clk = ~clk;
		end
	end

	initial begin
		uvm_config_db#(virtual ps2_if)::set(null, "*", "ps2_vif", dut_if);
		run_test("test");
	end

endmodule