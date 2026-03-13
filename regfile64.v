// regfile64.v
`timescale 1ns/1ps
module regfile64(
    input clk,
    input rst,
    // read ports
    input  [1:0] raddr0,
    output reg [63:0] rdata0,
    input  [1:0] raddr1,
    output reg [63:0] rdata1,
    // write port
    input  we,
    input  [1:0] waddr,
    input  [63:0] wdata
);

reg [63:0] regs [0:3];
integer i;

always @(posedge clk) begin
    if (rst) begin
        for (i=0; i<4; i=i+1) regs[i] <= 64'd0;
    end else begin
        if (we) regs[waddr] <= wdata;
    end
end

always @(*) begin
    rdata0 = regs[raddr0];
    rdata1 = regs[raddr1];
end

endmodule

