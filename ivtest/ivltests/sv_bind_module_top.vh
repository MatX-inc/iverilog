module bind_module_top;
  bind_module_dut #(3, 5) left();
  bind_module_dut #(7, 101) right();
  initial begin
    #2;
    if (left.named.checked != 1 || right.named.checked != 1 ||
        left.positional.checked != 1 || right.positional.checked != 1 ||
        left.second.checked != 1 || right.second.checked != 1 ||
        left.wildcard_probe.checked != 1 || right.wildcard_probe.checked != 1)
      $fatal(1, "missing or duplicate checker");
    $display("PASSED");
  end
endmodule
