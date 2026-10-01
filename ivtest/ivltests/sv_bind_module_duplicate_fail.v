module bind_duplicate_dut; endmodule
module bind_duplicate_probe; endmodule
bind bind_duplicate_dut bind_duplicate_probe monitor();
bind bind_duplicate_dut bind_duplicate_probe monitor();
module test;
  bind_duplicate_dut dut();
endmodule
