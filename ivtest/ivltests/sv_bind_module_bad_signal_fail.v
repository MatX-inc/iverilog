module bind_bad_signal_dut; endmodule
module bind_bad_signal_probe(input value); endmodule
bind bind_bad_signal_dut bind_bad_signal_probe monitor(.value(typo));
module test;
  bind_bad_signal_dut dut();
endmodule
