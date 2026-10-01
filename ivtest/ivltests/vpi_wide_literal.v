// Regression for https://github.com/steveicarus/iverilog/issues/1407.
module top;
  localparam [32767:0] PARAMETER_VALUE = 32768'b101;
  string text;

  task check_bits(input integer width, input string actual,
                  input [7:0] padding, input string tail);
    integer idx;
    begin
      if (actual.len() != width)
        $fatal(1, "width %0d: got %0d characters", width, actual.len());
      for (idx = 0; idx < width - tail.len(); idx = idx + 1)
        if (actual[idx] != padding)
          $fatal(1, "width %0d: incorrect padding at %0d", width, idx);
      if (actual.substr(width - tail.len(), width - 1) != tail)
        $fatal(1, "width %0d: incorrect low bits", width);
    end
  endtask

  initial begin
    $sformat(text, "%b", 4090'b1);
    check_bits(4090, text, "0", "1");

    $sformat(text, "%b", 8192'bx);
    check_bits(8192, text, "x", "x");

    $sformat(text, "%b", 32768'b10xz);
    check_bits(32768, text, "0", "10xz");

    $sformat(text, "%b", PARAMETER_VALUE);
    check_bits(32768, text, "0", "101");

    // The signed prefix needs one more byte at each former buffer boundary.
    $sformat(text, "%0d", -4089'sd1);
    if (text != "-1") $fatal(1, "4089-bit literal lost its signed value");
    $sformat(text, "%0d", -32760'sd1);
    if (text != "-1") $fatal(1, "32760-bit literal lost its signed value");
    $sformat(text, "%0d", -32768'sd1);
    if (text != "-1") $fatal(1, "32768-bit literal lost its signed value");

    $display("PASSED");
  end
endmodule
