module bind_nested_dut; endmodule
module bind_nested_first; endmodule
module bind_nested_second; endmodule
bind bind_nested_dut bind_nested_first first();
bind bind_nested_first bind_nested_second second();
module test;
  bind_nested_dut dut();
endmodule
