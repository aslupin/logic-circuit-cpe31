//typedef enum logic[2:0]{ A=3'b000, B=3'b001, C=3'b011, D=3'b111, AA=3'b000, BB=3'b100, CC=3'b110, DD=3'b111} state_t;
typedef enum logic[2:0]{ A=3'b111, B=3'b110, C=3'b100, D=3'b000} state_t;
typedef enum logic[2:0]{ AA=3'b111, BB=3'b110, CC=3'b100, DD=3'b000} state_tt;

module next_state(input logic k, si, sii,input state_t cs,input state_tt css, output state_t ns,output state_tt nss);
    always_comb begin
    if(k == 0) begin
        ns = (cs == A)? D:A;
        nss = (css == AA)? DD:AA;
    end 

    else if(si == 1) begin
			nss = AA;
        if(cs == A) 
            ns = B;
        else if(cs == B)
            ns = C;		
        else if(cs == C)
            ns = D;	
        else 
            ns = A;
    end 
    else if(sii == 1) begin
			ns = A;
        if(css == AA)
				nss = BB;
        else if(css == BB)
            nss = CC;
        else if(css == CC)
            nss = DD;
        else 
            nss = AA;
		
    end
    else begin 
		ns = A;
		nss = AA;
	 end
end
endmodule

module d_flipflop (input logic d, clk, output logic q);
    always_ff @(posedge clk) begin
        q <= d;
    end
endmodule

module gen_output(input state_t cs,input state_tt css, output logic ol, oll, olll, oor, orr, orrr);
	 always_comb begin
	 
		{olll,oll,ol} = cs;
		{orrr,orr,oor} = css;
		
	 end
endmodule

module fsm (input logic inKey, inSwI, inSwII, clk, output logic outl, outll, outlll, outr, outrr, outrrr);
    state_t cs, ns;
    state_tt cs_r, ns_r;
    
    initial begin
        ns = A;
        cs = A;
        cs_r = AA;
        ns_r = AA;
    end

    // Connect modules
    next_state nxt ( .cs(cs), .ns(ns), .css(cs_r), .nss(ns_r), .k(inKey), .si(inSwI), .sii(inSwII));

    d_flipflop b0_l ( .d(ns[0]), .clk(clk), .q(cs[0]) );
    d_flipflop b1_l ( .d(ns[1]), .clk(clk), .q(cs[1]) );
    d_flipflop b2_l ( .d(ns[2]), .clk(clk), .q(cs[2]) );

    d_flipflop b0_r ( .d(ns_r[0]), .clk(clk), .q(cs_r[0]) );
    d_flipflop b1_r ( .d(ns_r[1]), .clk(clk), .q(cs_r[1]) );
    d_flipflop b2_r ( .d(ns_r[2]), .clk(clk), .q(cs_r[2]) );

    gen_output gen ( .cs(cs), .css(cs_r), .ol(outl), .oll(outll), .olll(outlll), 
								  .oor(outr), .orr(outrr), .orrr(outrrr));
endmodule


module lab12(input logic clk, key, swi, swii, output logic li, lii, liii, ri, rii, riii);
	 integer counter;
	 logic clk_out,clk_use;
    initial begin
		  counter = 1000;
		  clk_use = 0;
		 
		  {li, lii, liii, ri, rii, riii} = 6'b111111;
        //$dumpfile("dump.vcd");
        //$dumpvars(1);
    end
    PLL pll_component(clk,clk_out);
	 fsm fsm1( .inKey(key), .inSwI(swi), .inSwII(swii), .outl(li), .outll(lii),
				  .outlll(liii), .outr(ri), .outrr(rii), .outrrr(riii), .clk(clk_use) );
    always_ff @(posedge clk_out) begin
   	 if(counter != 0)
   		 counter = counter - 1;
   	 else begin
   		 counter = 1000;
			 clk_use = ~clk_use;
			
   	 end
    end
endmodule
