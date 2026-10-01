module bind_instance_dut; endmodule
module bind_instance_probe; endmodule
module test;
  bind_instance_dut dut();
endmodule
bind test.dut bind_instance_probe monitor();
