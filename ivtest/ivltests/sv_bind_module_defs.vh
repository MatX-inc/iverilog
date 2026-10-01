module bind_module_dut #(parameter W = 3, TAG = 5);
  logic [W-1:0] hidden = TAG;
  wire [W:0] echo = {1'b0, hidden};
endmodule

module bind_module_probe #(parameter W = 1, TAG = -1, SIZE = 0)
  (input [W-1:0] hidden, input [W:0] echo);
  integer checked = 0;
  initial begin
    #1;
    if (TAG < 0 || SIZE != W || hidden !== W'(TAG) ||
        echo !== {1'b0, W'(TAG)} || $bits(hidden) != W)
      $fatal(1, "wrong bind target scope, specialization, or root: %m");
    checked = 1;
  end
endmodule
