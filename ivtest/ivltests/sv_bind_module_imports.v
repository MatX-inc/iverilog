package bind_import_a;
  parameter int sig = 0;
endpackage
package bind_import_b;
  parameter int sig = 2;
endpackage
package bind_import_target;
  parameter int ONLY_IN_TARGET = 17;
endpackage
import bind_import_a::*;
import bind_import_b::*;
// The CU ambiguity is irrelevant: sig is a target-local name.
bind bind_import_dut bind_import_probe #(.EXPECTED(ONLY_IN_TARGET))
  monitor(.sig(sig));
module bind_import_dut;
  import bind_import_target::*;
  logic sig = 1;
endmodule
module bind_import_probe #(parameter EXPECTED = -1)(input sig);
  integer checked = 0;
  initial begin
    #1;
    if (sig !== 1'b1 || EXPECTED != 17) $fatal(1, "wrong bind import scope");
    checked = 1;
  end
endmodule
module bind_import_top;
  bind_import_dut dut();
  initial begin
    #2;
    if (dut.monitor.checked != 1) $fatal(1, "checker missing");
    $display("PASSED");
  end
endmodule
