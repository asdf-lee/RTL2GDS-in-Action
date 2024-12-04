
module Decoder(
    `ifdef USE_POWER_PINS
        inout vdd,                  // Supply
        inout vss,                  // GND
    `endif

    input [8:0] io_in,              // Inputs
    input wb_clk_i,                 // Clock
    output [3:0] io_out,            // Outputs

    output [12:0] io_oeb 	     // Output Enable Bar
);

// Inputs
    wire [6:0] Comp;
    wire Samp;

    assign Comp = io_in[6:0];      // Comparison signals
    assign Samp = io_in[7];        // Sampling

    wire clk;
    assign clk = wb_clk_i;         // Clock

// Outputs
    reg eoc;
    reg [2:0] B;

    assign io_out[2:0] = B;        // Bits
    assign io_out[3] = eoc;        // End of Conversion

    // Output enable logic
    assign io_oeb = {{(9){1'b1}}, 4'b0};

    // Decoder:
    // Next Bit value
    reg [2:0] Bx;

    always @* begin
        case (Comp)
            7'b0000000: Bx = 3'b000;
            7'b0000001: Bx = 3'b001;
            7'b0000011: Bx = 3'b010;
            7'b0000111: Bx = 3'b011;
            7'b0001111: Bx = 3'b100;
            7'b0011111: Bx = 3'b101;
            7'b0111111: Bx = 3'b110;
            7'b1111111: Bx = 3'b111;
            default: Bx = 3'b000;
        endcase
    end

    always @(posedge clk) begin
        if (Samp) begin
            B[2:0] <= 3'd0;
            eoc <= 1'd0;
        end else begin
            B[2:0] <= Bx;
            eoc <= 1'd1;
        end
    end

endmodule