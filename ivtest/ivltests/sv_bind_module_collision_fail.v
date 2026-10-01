module bind_collision_dut;
  wire monitor;
endmodule
module bind_collision_probe; endmodule
bind bind_collision_dut bind_collision_probe monitor();
module test;
  bind_collision_dut dut();
endmodule
