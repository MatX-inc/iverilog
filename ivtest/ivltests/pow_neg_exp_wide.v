/*
 * pow_neg_exp_wide
 * Check that the power operator returns the values given in table 5-6 of
 * IEEE 1364-2005 for a negative exponent when the operands are wider than
 * 32 bits. Both the procedural and continuous assignment paths are checked,
 * and the operands are not constant so the result is computed by vvp.
 */

module check_pow;
   parameter WIDTH = 32;

   reg  signed [WIDTH-1:0] base, exp, res;
   wire signed [WIDTH-1:0] ca_res = base ** exp;
   reg pass;

   task check;
      input signed [WIDTH-1:0] b;
      input signed [WIDTH-1:0] e;
      input signed [WIDTH-1:0] expected;
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
      check( 0, -1, 'bx);
      check( 1, -1, 1);
      check( 1, -2, 1);
      check(-1, -1, -1);
      check(-1, -2, 1);
      check(-1, {1'b1, {WIDTH-1{1'b0}}}, 1);
      check( 2, -1, 0);
      check(-2, -1, 0);
   end

endmodule // check_pow

module main;

   check_pow #(32) p32();
   check_pow #(33) p33();
   check_pow #(64) p64();
   check_pow #(65) p65();
   check_pow #(128) p128();

   initial begin
      #100;
      if (p32.pass && p33.pass && p64.pass && p65.pass && p128.pass)
	 $display("PASSED");
      $finish;
   end

endmodule // main
