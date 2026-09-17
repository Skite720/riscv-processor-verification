module register_file (
    input  logic        clk,        // System heartbeat clock
    input  logic        rst_n,      // Active-low reset signal
    input  logic [4:0]  rs1_addr,   // 5 wires selecting Source Reg 1 (0-31)
    input  logic [4:0]  rs2_addr,   // 5 wires selecting Source Reg 2 (0-31)
    input  logic [4:0]  rd_addr,    // 5 wires selecting Destination Reg (0-31)
    input  logic [31:0] write_data, // 32 wires carrying data to store
    input  logic        reg_write,  // 1-bit write enable switch

    output logic [31:0] rs1_data,   // 32 output wires for Source Reg 1 value
    output logic [31:0] rs2_data    // 32 output wires for Source Reg 2 value
);

    // 32 registers, each 32 bits wide (Storage flip-flops)
    logic [31:0] registers [31:0];

    // CONTINUOUS READS (Combinational MUX Logic)
    // Register x0 is physically hardwired to always read as 0
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : registers[rs2_addr];

    // SYNCHRONOUS WRITES (Clocked Flip-Flop Logic)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear all 32 registers to 0 on reset
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            // Latch data into target register on rising clock edge (ignore x0)
            registers[rd_addr] <= write_data;
        end
    end

endmodule