module bind_shadow_probe(input value);
  integer checked = 0;
  initial begin
    #1;
    if (value !== 1'b1) $fatal(1, "wrong bind scope");
    checked = 1;
  end
endmodule
module bind_shadow_dut;
  wire value = 1'b1;
  module bind_shadow_probe(input unused);
    initial $fatal(1, "nested type captured CU checker name");
  endmodule
endmodule
module bind_shadow_other;
endmodule
bind bind_shadow_dut bind_shadow_probe monitor(.value(value));
module bind_shadow_top;
  bind_shadow_dut dut();
  // An unrelated instance name must not override the target module type.
  bind_shadow_other bind_shadow_dut();
  initial begin
    #2;
    if (dut.monitor.checked != 1) $fatal(1, "wrong bind type");
    $display("PASSED");
  end
endmodule
