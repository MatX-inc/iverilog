module bind_enum_dut; endmodule
module bind_enum_probe #(parameter W = 1); endmodule
bind bind_enum_dut bind_enum_probe #(.W($bits(enum {BIND_ENUM_VALUE}))) monitor();
module test; endmodule
