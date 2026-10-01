module bind_list_dut; endmodule
module bind_list_probe; endmodule
module test;
  bind_list_dut dut();
endmodule
bind bind_list_dut : test.dut bind_list_probe monitor();
