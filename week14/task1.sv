module input(input logic inp, clk, output logic checkinput);
	integer counter = 0;
	initial checkinput = 1;
	always @(posedge clk) begin 
		if (inp == checkinput)
			counter = 0;
		else begin
			if (counter == 8) checkinput <= inp;
			else counter += 1;
		end
	end
endmodule

module adder(input logic k_i, k_ii, s_i, s_ii, clk, output logic [7:0] l);
	logic ch;
	logic [7:0] o = 8'b0000_0000;
	input inp ( .inp(k_i), .clk(clk), .checkinput(ch));
	integer counter = 0;
	logic state = 1;
	always @(posedge clk) begin 
		if (k_ii == 0) begin 
			o = 8'b0000_0000;
			counter = 0;
		end
		else if(ch == 0 && state == 1) begin
			state = 0;
            if (counter == 7)
				o[counter] = (s_i^s_ii)^o[counter];

			else if (counter < 7) begin
				o[counter+1] = (s_i&s_ii) | (o[counter]&(s_i|s_ii));
				o[counter] = (s_i^s_ii)^o[counter];
				counter += 1;
			end
			counter += 1;
		end
		else
			state = ch;
		l = ~o; 
	end 
endmodule
