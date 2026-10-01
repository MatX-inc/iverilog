module bind_missing_dut; endmodule
bind bind_missing_dut no_such_checker monitor();
// Unknown bound types must fail even when no target instance is elaborated.
module test; endmodule
