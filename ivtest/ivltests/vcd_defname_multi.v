// Exercises the `$comment defname <type> $end` line for module scopes.

module top;
   wire a;
   wire b1, b2, b3;
   wire c;

   reg in;

   inverter inv1 (in, b1);
   inverter inv2 (in, b2);
   inverter inv3 (in, b3);
   buffer   buf1 (in, c);

   initial begin
      $dumpfile("work/vcd_defname_multi.vcd");
      $dumpvars(0, top);
      in = 1'b0;
      #1 in = 1'b1;
      #1 in = 1'b0;
      $finish;
   end
endmodule

module inverter(input wire x, output wire y);
   assign y = ~x;
endmodule

module buffer(input wire x, output wire y);
   assign y = x;
endmodule
