module asm_test (output logic sel_i, sel_ii, cl, ld, bits_ii);
    initial begin
         
    end
endmodule
module lab13;

    function logic [7:0] mux(input logic [7:0] in_i, in_ii,input logic sel);
        if(sel = 0) max = in_i;
        else mux = in_ii;
    endfunction

    function reg [7:0] register (input reg [7:0] inp, input logic clk, ld, cl);
        @posedge(clk) begin
            if(cl == 1)
                return 8'b0000_0000;
            else if(cl == 0 && ld == 1) 
                return inp;
        end 
    endfunction

    function reg [7:0] shifter (input reg[7:0] inp,input logic func);
        if(func == 2'b00 )
            return inp;
        else if(func == 2'b01 )
            return inp >>> 1;
        else 
            return inp <<< 1;
    endfunction


    input [7:0] logic dp,regis;
    input [7:0] logic a;
    input [7:0] logic b;
    input logic clk;
    logic clk_out;
    logic dp, sel_i, sel_ii;
    logic [1:0] bits_ii;
    logic cl,ld;

    initial begin
        regis = 8'b0000_0000;
        a = 8'b1000_0000;
        b = 8'b0000_0001;
        // a = 8'b0111_1111;
        // b = 8'b1111_1110;
        sel_i = {1};
        sel_ii = {1};
        bits_ii = {0,0};
    end

    dp = mux( .in_i(a), .in_ii(b), .sel(sel_i);
    PLL pll_component(clk,clk_out);

    always_comb begin
            dp = mux( .in_i(a), .in_ii(b), .sel(sel_ii) );
            dp = shifter( .inp(dp), .func(bits_ii) );
        always_ff @(posedge clk_out) begin    
            regis  = register( .inp(dp), .clk(clk), .cl(cl), .ld(ld))
        end
    end

endmodule