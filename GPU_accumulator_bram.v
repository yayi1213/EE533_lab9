// dot_accumulator_bram.v
`timescale 1ns/1ps
module dot_accumulator_bram(
    input clk,
    input rst,
    input start,                // one-cycle pulse to start
    input [7:0] iterations,     // number of dot4 calls
    input [31:0] base_addr,     // word address base (index)
    // BRAM interface (controller side)
    output reg [31:0] rd_addr,  // address to read (word index)
    output reg rd_en,           // assert to request read; data valid next cycle
    input [63:0] a_data,        // BRAM returns 4×16b: {a3,a2,a1,a0}
    input [63:0] b_data,        // BRAM returns 4×16b: {b3,b2,b1,b0}
    output reg done,
    output reg [31:0] result
);

wire [15:0] a0,a1,a2,a3,b0,b1,b2,b3;
reg [7:0] counter;
reg [31:0] acc;
reg running;
reg data_consumed;
reg read_pending;

assign a0 = a_data[15:0];
assign a1 = a_data[31:16];
assign a2 = a_data[47:32];
assign a3 = a_data[63:48];

assign b0 = b_data[15:0];
assign b1 = b_data[31:16];
assign b2 = b_data[47:32];
assign b3 = b_data[63:48];

wire [31:0] dot_out;
dot4 u_dot4(
    .a0(a0), .a1(a1), .a2(a2), .a3(a3),
    .b0(b0), .b1(b1), .b2(b2), .b3(b3),
    .result(dot_out)
);

always @(posedge clk) begin
    if (rst) begin
        rd_addr <= 0;
        rd_en <= 0;
        acc <= 0;
        counter <= 0;
        done <= 0;
        result <= 0;
        running <= 0;
        read_pending <= 0;
        data_consumed <= 1;
    end else begin
        if (start && !running) begin
            rd_addr <= base_addr;
            rd_en <= 1;
            counter <= iterations;
            acc <= 0;
            done <= 0;
            running <= 1;
            read_pending <= 1;
            data_consumed <= 1;
        end else if (running) begin
            if (rd_en && read_pending) begin
                rd_en <= 0;
            end

            if (read_pending && data_consumed) begin
                if (counter > 0) begin
                    acc <= acc + dot_out;
                    counter <= counter - 1;
                end
                data_consumed <= 0;

                if (counter > 1) begin
                    rd_addr <= rd_addr + 1;
                    rd_en <= 1;
                    read_pending <= 1;
                    data_consumed <= 1;
                end else begin
                    result <= acc + dot_out;
                    done <= 1;
                    running <= 0;
                    read_pending <= 0;
                end
            end
        end
    end
end

endmodule
