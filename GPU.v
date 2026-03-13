module dot4(
    input  [15:0] a0,a1,a2,a3,
    input  [15:0] b0,b1,b2,b3,
    output [31:0] result
);

assign result = a0*b0 + a1*b1 + a2*b2 + a3*b3;

endmodule