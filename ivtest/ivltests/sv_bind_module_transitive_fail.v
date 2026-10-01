module bind_transitive_dut; endmodule
module bind_transitive_child; endmodule
module bind_transitive_first;
  bind_transitive_child child();
endmodule
module bind_transitive_second; endmodule
bind bind_transitive_dut bind_transitive_first first();
bind bind_transitive_child bind_transitive_second second();
module test;
  bind_transitive_dut dut();
endmodule
