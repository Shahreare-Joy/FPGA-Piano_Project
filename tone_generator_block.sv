// ============================================================================
// tone_generator_block.sv
// ============================================================================

module tone_generator_block(
    input logic clk,
    input logic enable,
    input logic [31:0] divider_value,
    output logic audio_out
);

    logic [31:0] counter;

    always_ff @(posedge clk) begin
        if (!enable) begin
            counter   <= 32'd0;
            audio_out <= 1'b0;
        end
        else begin
            if (counter >= (divider_value - 1)) begin
                counter   <= 32'd0;
                audio_out <= ~audio_out;
            end
            else begin
                counter <= counter + 32'd1;
            end
        end
    end

endmodule
