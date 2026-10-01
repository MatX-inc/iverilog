module bind_contained_dut; endmodule
module bind_contained_probe; endmodule
module test;
  bind bind_contained_dut bind_contained_probe monitor();
endmodule
