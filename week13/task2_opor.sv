typedef enum logic[1:0]{ A=2'b00, B=2'b01, C=2'b10, D=2'b11 } state_t;

module register(input logic load, clk, clr, input logic [7:0] inp, output logic [7:0] out);
    logic [7:0] regis;
	 //PLL pll_component(clk, clk_out);
	 always_ff @ (posedge clk) begin
			if(clr == 1) regis = 8'b00000000;
			else if(load == 1) regis = inp;
			else regis = regis;
			out = regis;
    end
endmodule

module shifter(input logic [7:0] inp, input logic [1:0] func, output logic [7:0] out);
		 always_comb begin
			 if(func == 2'b00) out = inp;
			 else if(func == 2'b01) begin 
				if(inp == 8'b10000000) out = 8'b00000001;
				else out = inp<<1;
			 end
			 else begin
				if(inp == 8'b00000001) out = 8'b10000000; 
				else out = inp>>1;
			 end
		 end
endmodule

module d_flipflop (input state_t d, input logic clk, output state_t q);
	//PLL pll_component(clk, clk_out);
   always_ff @(posedge clk) begin
		q <= d;
   end
endmodule

module next_state_LR(input state_t cs, output state_t ns, output logic sel1, sel2, load, clr, output logic [1:0] func);//, output logic sel1, sel2, load, clr, func);
	 always_comb begin
		if(cs == B) begin
			ns = B;
			sel1=0;
			sel2=0;
			load=1;
			clr=0;
			func=2'b11;
		end
		else begin
			ns=B;
			sel1=0;
			sel2=1;
			load=1;
			clr=0;
			func=2'b11;
	 	end
	 end
endmodule

module next_state_RL(input state_t cs, output state_t ns, output logic sel1, sel2, load, clr, output logic [1:0] func);//, output logic sel1, sel2, load, clr, func);
	 always_comb begin
		if(cs == B) begin
			ns = B;
			sel1=1;
			sel2=0;
			load=1;
			clr=0;
			func=2'b01;
		end
		else begin
			ns=B;
			sel1=1;
			sel2=1;
			load=1;
			clr=0;
			func=2'b01;
	 	end
	 end
endmodule

module next_state_LR2RL2(input state_t cs, output state_t ns, output logic sel1, sel2, load, clr, count, 
	output logic [1:0] func, input logic [7:0] out);
	 always_comb begin //func 01: Right to left   //     1x: Left to Right
		if(cs == B) begin // left to right
			func= (count==1 & out==8'b00000001)? 2'b01:2'b11;
			ns = (count==1 & out==8'b00000001)? C:B;
			if(count==0) count=(out==8'b00000001)? 1:0;
			else count=(out==8'b000000001)? 0:1;
			sel1=0; //dont care
			sel2=0;
			load=1;
			clr=0;
		end
		else if(cs == C) begin // right to left
			func= (count==1 & out==8'b10000000)? 2'b11:2'b01;
			ns = (count==1 & out==8'b10000000)? B:C;
			if(count==0) count=(out==8'b10000000)? 1:0;
			else count=(out==8'b10000000)? 0:1;
			sel1=1; //dont care
			sel2=0;
			load=1;
			clr=0;
		end
		else begin // Initial load
			ns=B;
			sel1=0;
			sel2=1;
			load=1;
			clr=0;
			func=2'b11;
			count=0;
	 	end
	 end
endmodule

module gen_output(input state_t cs, input logic [7:0] out, output logic led7, led6, led5, led4, led3, led2, led1, led0);
	always_comb begin
		{led7, led6, led5, led4, led3, led2, led1, led0} = out;
	end
endmodule

module datapath(input logic clk, sel1, sel2, load, clr, input logic [1:0] func, output logic [7:0] out);
    logic [7:0] select1, select2, shift;
	 initial out = 8'b00000000;
    always_comb begin
        select1 = (sel1==0)? 8'b00000001:8'b10000000; //
        select2 = (sel2==0)? out:select1;
    end
	 shifter sh1 (.inp(select2), .func(func), .out(shift));
	 register r1 (.clk(clk), .inp(shift), .load(load), .clr(clr), .out(out));
endmodule

module asm(input logic clk, output logic sel1, sel2, load, clr, count, input logic [7:0] out, output logic [1:0] func, output logic led7, led6, led5, led4, led3, led2, led1, led0);
	 state_t cs,ns;
	 next_state_LR LR (.cs(cs), .ns(ns), .sel1(sel1), .sel2(sel2), .load(load), .clr(clr), .func(func));
	 //next_state_RL RL (.cs(cs), .ns(ns), .sel1(sel1), .sel2(sel2), .load(load), .clr(clr), .func(func));
	 //next_state_LR2RL2 RRLL (.count(count), .cs(cs), .ns(ns), .sel1(sel1), .sel2(sel2), .load(load), .clr(clr), .func(func), .out(out));
	 d_flipflop b0 ( .d(ns), .clk(clk), .q(cs));
	 gen_output out_comb (.cs(cs), .out(out), .led0(led0), .led1(led1), .led2(led2), .led3(led3), .led4(led4), .led5(led5), .led6(led6), .led7(led7));
endmodule

module testbench(output logic clk, input logic led7, led6, led5, led4, led3, led2, led1, led0);
    integer i;
	 initial begin
        clk = 0;
		  for(i=0; i<200; i++) #15 clk = ~clk;
    end
endmodule

module top(output opor);
	 logic sel1,sel2,load,clr,clk,count;
	 logic led7, led6, led5, led4, led3, led2, led1, led0;
	 logic [1:0] func;
	 logic [7:0] out;
     
  	testbench tb (.clk(clk), .led0(led0), .led1(led1), .led2(led2), .led3(led3), .led4(led4), .led5(led5), .led6(led6), .led7(led7));
	asm flow (.count(count), .clk(clk), .out(out), .sel1(sel1), .sel2(sel2), .load(load), .clr(clr), .func(func), .led0(led0), .led1(led1), .led2(led2), .led3(led3), .led4(led4), .led5(led5), .led6(led6), .led7(led7));
	datapath p1 (.clk(clk), .sel1(sel1), .sel2(sel2), .load(load), .clr(clr), .func(func), .out(out));
endmodule
