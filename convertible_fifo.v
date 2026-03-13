// convertible_fifo_arm.v
// Adapted for ARM CPU DM interface (32-bit words, 128 words deep)
// - W = 32
// - ADDR_WIDTH = 7 (2^7 = 128 words)
// - CTRL_REG_ADDR = all ones (address 7'b111_1111 = 127) reserved for processor release command
// - Port A: writer (netfpga input)
// - Port B: read port (either streaming output or processor access when proc_sel==1)

module convertible_fifo #(
    parameter W = 32,
    parameter ADDR_WIDTH = 7  // 2^7 = 128 words
)(
    input  wire                 clk,
    input  wire                 rstn,
    // netfpga input (writer)
    input  wire [W-1:0]         in_data,
    input  wire                 in_valid,
    input  wire                 in_sop, // start of packet
    input  wire                 in_eop, // end of packet
    output reg                  in_rdy,     // when 0 upstream should stall

    // fifo output (to network or next stage) - read port
    input  wire                 out_rd_en,
    output wire [W-1:0]         out_data,
    output wire                 out_valid,
    output wire                 out_sop,
    output wire                 out_eop,

    // processor mmio access (simple) - maps to ARM CPU memory port B
    input  wire                 proc_sel,    // when 1 processor takes control of BRAM read/write
    input  wire [ADDR_WIDTH-1:0] proc_addr,
    input  wire [W-1:0]         proc_wdata,
    input  wire                 proc_we,
    output wire [W-1:0]         proc_rdata,

    // status regs (module outputs)
    output reg                  packet_ready,
    output reg [ADDR_WIDTH-1:0] head_addr_reg,
    output reg [ADDR_WIDTH-1:0] tail_addr_reg
);

    localparam [ADDR_WIDTH-1:0] CTRL_REG_ADDR = {ADDR_WIDTH{1'b1}};

    // internal pointers
    reg [ADDR_WIDTH-1:0] write_ptr; 
    reg [ADDR_WIDTH-1:0] read_ptr;
    reg [ADDR_WIDTH-1:0] portb_addr;

    // state
    reg buffering; // indicates we're in the middle of receiving a packet (after SOP, before EOP)

    // BRAM model
    reg [W-1:0] bram [0:(1<<ADDR_WIDTH)-1];
    reg [1:0]   ctrl_bram [0:(1<<ADDR_WIDTH)-1]; // {SOP, EOP}

    // registered outputs from port B (synchronous read)
    reg [W-1:0] portb_rdata;
    reg [1:0]   portb_ctrl; 

    wire data_available_for_out;
    assign data_available_for_out = packet_ready && (read_ptr != tail_addr_reg);

    assign out_data  = portb_rdata; // when proc_sel=0, portb_rdata reflects FIFO output; when proc_sel=1, it reflects processor read
    assign out_valid = data_available_for_out && !proc_sel;  // only valid for streaming output, not when processor is accessing
    assign out_sop   = portb_ctrl[1];// SOP bit from control BRAM
    assign out_eop   = portb_ctrl[0];// EOP bit from control BRAM

    assign proc_rdata = portb_rdata; // processor reads always get the port B data (which is either FIFO output or processor-accessible BRAM depending on proc_sel)

    // Write side (port A)
    always @(posedge clk) begin
        if (!rstn) begin
            write_ptr     <= {ADDR_WIDTH{1'b0}};
            tail_addr_reg <= {ADDR_WIDTH{1'b0}};
            buffering     <= 1'b0;
            packet_ready  <= 1'b0;
            in_rdy        <= 1'b1; // ready to accept data
        end else begin
            if (in_valid && in_rdy) begin
                bram[write_ptr] <= in_data; // write data to BRAM
                ctrl_bram[write_ptr] <= {in_sop, in_eop}; // write control bits
                write_ptr <= write_ptr + 1'b1; 
                tail_addr_reg <= write_ptr + 1'b1;
                buffering <= 1'b1;
                if (in_eop) begin
                    packet_ready <= 1'b1;
                    buffering <= 1'b0;
                    in_rdy <= 1'b0;
                end
            end
        end
    end

    // Port B address selection
    always @(posedge clk) begin 
        if (!rstn) portb_addr <= {ADDR_WIDTH{1'b0}};
        else begin
            if (proc_sel) portb_addr <= proc_addr; 
            else portb_addr <= read_ptr; 
        end
    end

    // Port B synchronous read
    always @(posedge clk) begin
        if (!rstn) begin
            portb_rdata <= {W{1'b0}};
            portb_ctrl  <= 2'b00;
        end else begin
            portb_rdata <= bram[portb_addr];
            portb_ctrl  <= ctrl_bram[portb_addr];
        end
    end

    // Output read pointer update
    always @(posedge clk) begin
        if (!rstn) begin
            read_ptr <= {ADDR_WIDTH{1'b0}};
            head_addr_reg <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (!proc_sel) begin
                if (out_rd_en && data_available_for_out) begin
                    read_ptr <= read_ptr + 1'b1;
                    head_addr_reg <= read_ptr + 1'b1;
                end
            end
        end
    end

    // Processor writes / control reg handling (port B write)
    always @(posedge clk) begin
        if (!rstn) begin
            // nothing
        end else begin
            if (proc_sel && proc_we) begin
                if (proc_addr == CTRL_REG_ADDR) begin
                    if (proc_wdata[0]) begin
                        // processor releases packet after processing
                        head_addr_reg <= tail_addr_reg; // move head to tail to mark packet as consumed
                        read_ptr <= tail_addr_reg; // reset read pointer to tail
                        packet_ready <= 1'b0;
                        in_rdy <= 1'b1;
                    end
                end else begin
                    bram[proc_addr] <= proc_wdata;
                end
            end
        end
    end

endmodule