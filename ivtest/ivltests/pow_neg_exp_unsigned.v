/*
 * pow_neg_exp_unsigned
 * Check that the power operator does not treat an unsigned base as a
 * signed value when the exponent is signed. An unsigned base with all
 * bits set is a large positive value, not -1, so raising it to a negative
 * power gives 0. Both the procedural and continuous assignment paths are
 * checked, and the operands are not constant so the result is computed
 * by vvp.
 */

module check_pow;
   parameter WIDTH = 32;
   parameter EWIDTH = 32;

   reg         [WIDTH-1:0]  base, res;
   reg  signed [EWIDTH-1:0] exp;
   wire        [WIDTH-1:0]  ca_res = base ** exp;
   reg pass;

   task check;
      input        [WIDTH-1:0]  b;
      input signed [EWIDTH-1:0] e;
      input        [WIDTH-1:0]  expected;
      begin
	 base = b;
	 exp = e;
	 res = base ** exp;
	 #1;
	 if (res !== expected) begin
	    $display("FAILED -- %0d-bit procedural %0d ** %0d = %0d, expected %0d",
		     WIDTH, b, e, res, expected);
	    pass = 1'b0;
	 end
	 if (ca_res !== expected) begin
	    $display("FAILED -- %0d-bit continuous %0d ** %0d = %0d, expected %0d",
		     WIDTH, b, e, ca_res, expected);
	    pass = 1'b0;
	 end
      end
   endtask

   initial begin
      pass = 1'b1;
      check({WIDTH{1'b1}}, -1, 0);
      check({WIDTH{1'b1}}, -2, 0);
      check({WIDTH{1'b1}}, 3, {WIDTH{1'b1}});
      check(0, -1, 'bx);
      check(1, -1, 1);
      check(2, -1, 0);
   end

endmodule // check_pow

module main;

   check_pow #(8, 8) p8();
   check_pow #(32, 32) p32();
   check_pow #(33, 33) p33();
   check_pow #(64, 64) p64();
   check_pow #(65, 65) p65();
   check_pow #(16, 4) p16_4();
   check_pow #(8, 64) p8_64();

   initial begin
      #100;
      if (p8.pass && p32.pass && p33.pass && p64.pass && p65.pass &&
	  p16_4.pass && p8_64.pass)
	 $display("PASSED");
      $finish;
   end

endmodule // main
