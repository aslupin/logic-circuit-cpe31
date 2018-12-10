// typedef enum logic[2:0]{ AA=3'b111, BB=3'b110, CC=3'b100, DD=3'b000} state_tt;

module register (input logic [7:0] inp, input logic clk, ld, cl, output logic [7:0] regis);
		logic [7:0] regis_store; 
        always_ff @(posedge clk) begin
            if(cl == 1)
                regis_store <= 8'b0000_0000;
            else if(cl == 0 && ld == 1) 
                regis_store <= inp;
				else
					regis_store = regis_store;
        end 
		  // this scpoe for storage inp in register, cant assign data in parameter:declare register_store for this point.
		  always_comb begin
			 regis = regis_store;
		  end
		  
endmodule

module shifter (input logic func, output logic[7:0] inp);
	always_comb begin
        if(func == 2'b00)
            inp = inp;
        else if(func == 2'b01)
            inp = inp << 1;
        else if(func == 2'b10)
            inp = inp >> 1;
		  else
			inp = inp >> 1;
	end
endmodule

module datapath_m(input logic clk, sel_i, sel_ii, cl, ld,input logic [1:0] funcc,output logic [7:0] o);

	logic [7:0] a,b;
    logic [7:0] dp, regis, dp_init;

    initial begin
		a = 8'b1000_0000;
		b = 8'b0000_0001;
		dp_init = 8'b0000_0000;
        regis = 8'b0000_0000;
        dp = 8'b0000_0000;
    end
	 
    assign dp_init = (sel_i == 1)? a : b;
	assign dp = (sel_ii == 1)? dp : dp_init;
    shifter sf( .inp(dp), .func(funcc) );
	register re ( .inp(dp), .clk(clk), .cl(cl), .ld(ld), .regis(o));
	 
endmodule


module fsm (input logic clk, output logic li, lii, liii, liv, lv, lvi, lvii, lviii);
	logic [1:0] ns;
	//logic [1:0] ns_funcc;
	logic [7:0] fromdap;
    logic sel_i, sel_ii, cl, ld;
	logic [1:0] funcc;
	 
    initial begin
	    fromdap = 8'b0000_0000;
		sel_i = 0;
		sel_ii = 1;
		cl = 0;
		ld = 1;
		funcc = 2'b01;
    end

    // Connect modules
	 next_state nxt (.sel_ii(sel_ii), .ns(ns), .o(fromdap));
	 d_flipflop ff_sel_ii ( .d(ns[0]), .clk(clk), .q(sel_ii) );
    d_flipflop ff_cl ( .d(ns[1]), .clk(clk), .q(cl) );
	 datapath_m data ( .clk(clk), .sel_i(sel_i), .sel_ii(sel_i), .cl(cl), .ld(ld), .funcc(funcc), .o(fromdap));
    gen_output gen ( .fromdap(fromdap), .li(li), .lii(lii), .liii(liii), .liv(liv), .lv(lv), .lvi(lvi), .lvii(lvii), .lviii(lviii));
	 
endmodule

module next_state(input logic [7:0] o, input logic sel_ii, output logic [1:0] ns);
	always_comb begin	
		if(sel_ii == 1) begin
			if(o == 8'b0000_0000) ns = 2'b01;
			else ns = 2'b10;
		end
		else begin
			ns = 2'b10;
		end
	end
endmodule

module d_flipflop (input logic d, clk, output logic q);
    always_ff @(posedge clk) begin
        q <= d;
    end
endmodule

module gen_output(input logic [7:0] fromdap, output logic li, lii, liii, liv, lv, lvi, lvii, lviii);
	 always_comb begin
	 
		{li, lii, liii, liv, lv, lvi, lvii, lviii} = ~fromdap;
		
	 end
endmodule

//module lab13(input logic clk, key, swi, swii, output logic li, lii, liii, ri, rii, riii);
module datapath(input logic clk, output logic li, lii, liii, liv, lv, lvi, lvii, lviii );
	 integer counter;
	 logic clk_out,clk_use;
    initial begin
		  counter = 1000;
		  clk_use = 0;
		  {li, lii, liii, liv, lv, lvi, lvii, lviii} = 8'b1111_1111;
    end
    PLL pll_component(clk,clk_out);
	 fsm fsm1( .clk(clk_use), .li(li), .lii(lii), .liii(liii), .liv(liv), .lv(lv), .lvi(lvi), .lvii(lvii), .lviii(lviii));
    always_ff @(posedge clk_out) begin
   	 if(counter != 0)
   		 counter = counter - 1;
   	 else begin
   		 counter = 1000;
			 clk_use = ~clk_use;
			
   	 end
    end
endmodule