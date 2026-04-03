// ============================================================================
// note_select_block.sv
// ============================================================================

//  *****************************Note Select************************************************
// Mapping used here:
//   keys[6] -> C4
//   keys[5] -> D4
//   keys[4] -> E4
//   keys[3] -> F4
//   keys[2] -> G4
//   keys[1] -> A4
//   keys[0] -> B4
//  *****************************************************************************

module note_select_block(
    input logic [6:0] keys,
    output logic [31:0] divider_value,
    output logic any_key,
    output logic [3:0] note_num
);

    // 50 MHz clock, so:
    // divider = 50,000,000 / (2 * frequency)

    localparam int DIV_C4 = 32'd95556;
    localparam int DIV_D4 = 32'd85131;
    localparam int DIV_E4 = 32'd75843;
    localparam int DIV_F4 = 32'd71633;
    localparam int DIV_G4 = 32'd63776;
    localparam int DIV_A4 = 32'd56818;
    localparam int DIV_B4 = 32'd50607;

    always_comb begin
        any_key = 1'b0;
        divider_value = 32'd0;
        note_num = 4'd0;

        if (keys[0]) begin
            any_key = 1'b1;
            divider_value = DIV_B4;
            note_num = 4'd7;
        end
        else if (keys[1]) begin
            any_key = 1'b1;
            divider_value = DIV_A4;
            note_num = 4'd6;
        end
        else if (keys[2]) begin
            any_key = 1'b1;
            divider_value = DIV_G4;
            note_num = 4'd5;
        end
        else if (keys[3]) begin
            any_key = 1'b1;
            divider_value = DIV_F4;
            note_num = 4'd4;
        end
        else if (keys[4]) begin
            any_key = 1'b1;
            divider_value = DIV_E4;
            note_num = 4'd3;
        end
        else if (keys[5]) begin
            any_key = 1'b1;
            divider_value = DIV_D4;
            note_num = 4'd2;
        end
        else if (keys[6]) begin
            any_key = 1'b1;
            divider_value = DIV_C4;
            note_num = 4'd1;
        end
    end
endmodule
