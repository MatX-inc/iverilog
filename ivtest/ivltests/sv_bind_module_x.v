module bind_x_dut #(parameter BAD = 0);
  logic [2:0] hidden = 0;
  initial begin
    #1;
    if (BAD) hidden = 3'bx01;
    #1 hidden = 0;
  end
endmodule
module bind_x_probe(input [2:0] hidden);
  integer unknowns = 0;
  always @(hidden)
    if ((^hidden) === 1'bx) unknowns = unknowns + 1;
endmodule
bind bind_x_dut bind_x_probe monitor(.hidden(hidden));
module bind_x_top;
  bind_x_dut #(1) bad();
  bind_x_dut #(0) good();
  initial begin
    #3;
    if (bad.monitor.unknowns != 1 || good.monitor.unknowns != 0)
      $fatal(1, "checker missed X or shared state across target instances");
    $display("PASSED");
  end
endmodule
