module bind_array_dut #(parameter N = 3);
  wire value = 1'b1;
endmodule
module bind_array_probe(input value);
  integer checked = 0;
  initial begin
    #1;
    if (value !== 1'b1) $fatal(1, "bad array bind");
    checked = 1;
  end
endmodule
bind bind_array_dut bind_array_probe monitor[N-1:0](.value(value));
module bind_array_top;
  bind_array_dut #(2) dut();
  initial begin
    #2;
    if (dut.monitor[0].checked != 1 || dut.monitor[1].checked != 1)
      $fatal(1, "bound instance array missing");
    $display("PASSED");
  end
endmodule
