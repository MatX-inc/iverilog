// Actuals must resolve at the end of each target instance's scope.
bind bind_module_dut bind_module_probe
  #(.W(W), .TAG(TAG), .SIZE($bits(logic [W-1:0])))
  named(.hidden(W'((TAG > 0) ? +hidden : ~hidden)), .echo({1'b0, hidden[W-1:0]}));
bind bind_module_dut bind_module_probe #(W, TAG, W)
  positional(hidden, {1'b0, hidden}), second(hidden, {1'b0, hidden});
bind bind_module_dut bind_module_probe #(.W(W), .TAG(TAG), .SIZE(W))
  wildcard_probe(.*);
