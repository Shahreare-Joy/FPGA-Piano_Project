// ============================================================================
// hex_display_block.sv
// ============================================================================

//  HEX1 = note letter
//  HEX0 = octave number
//  *****************************************************************************

module hex_display_block(
    input logic any_key,
    input logic [3:0] note_num,
    output logic [7:0] hex0,
    output logic [7:0] hex1
);

    logic [6:0] seg0;
    logic [6:0] seg1;

    //  **************************************
    //  decimal digit on 7-segment
    //  **************************************
    function [6:0] seg_digit;
        input [3:0] d;
        begin
            case (d)
                4'd0: seg_digit = 7'b1000000;
                4'd1: seg_digit = 7'b1111001;
                4'd2: seg_digit = 7'b0100100;
                4'd3: seg_digit = 7'b0110000;
                4'd4: seg_digit = 7'b0011001;
                4'd5: seg_digit = 7'b0010010;
                4'd6: seg_digit = 7'b0000010;
                4'd7: seg_digit = 7'b1111000;
                4'd8: seg_digit = 7'b0000000;
                4'd9: seg_digit = 7'b0010000;
                default: seg_digit = 7'b1111111;
            endcase
        end
    endfunction

    //  **************************************
    //  letters on 7-segment
    //  **************************************
    function [6:0] seg_note;
        input [3:0] n;
        begin
            case (n)
                4'd1: seg_note = 7'b1000110; // C
                4'd2: seg_note = 7'b0100001; // d
                4'd3: seg_note = 7'b0000110; // E
                4'd4: seg_note = 7'b0001110; // F
                4'd5: seg_note = 7'b1000010; // G
                4'd6: seg_note = 7'b0001000; // A
                4'd7: seg_note = 7'b0000011; // b 
                default: seg_note = 7'b1111111;
            endcase
        end
    endfunction

    always_comb begin
        if (!any_key) begin
            seg0 = 7'b1111111; // off
            seg1 = 7'b1111111; // off
        end
        else begin
            seg0 = seg_digit(4'd4); // octave 4
            seg1 = seg_note(note_num);
        end
    end

    // [6:0] = segments, [7] = decimal point
    always_comb begin
        hex0[6:0] = seg0;
        hex0[7]   = 1'b1;

        hex1[6:0] = seg1;
        hex1[7]   = 1'b1;
    end
endmodule
