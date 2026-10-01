module bind_inactive_dut;
  wire value = 1'b1;
endmodule
module bind_inactive_probe(input value);
  if (0) begin
    bind_inactive_dut unused();
  end
  integer checked = 0;
  initial begin
    #1;
    if (value !== 1'b1) $fatal(1, "bad bind");
    checked = 1;
  end
endmodule
bind bind_inactive_dut bind_inactive_probe monitor(.value(value));
module bind_inactive_top;
  bind_inactive_dut dut();
  initial begin
    #2;
    if (dut.monitor.checked != 1) $fatal(1, "checker missing");
    $display("PASSED");
  end
endmodule
