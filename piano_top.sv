// ============================================================================
// piano_top.sv
// FPGA Piano Project 
// ============================================================================

module piano_top(
    output logic [7:0] hex0,
    output logic [7:0] hex1,
    output logic [9:0] ledr,
    inout wire  [7:0] arduino_io,
    input logic max10_clk1_50,
    input logic [9:0] sw
);

//  *****************************Key Input************************************************
    logic [6:0] keys_raw;
    logic [6:0] keys;

    assign keys_raw = arduino_io[6:0];

    // touch sensors are active-high
    assign keys = keys_raw;

    // set arduino pins 0-6 as inputs
    assign arduino_io[6:0] = 7'bzzzzzzz;

//  *****************************Note Select************************************************   
    logic [31:0] divider_value;
    logic any_key_pressed;
    logic [3:0] note_num;

    note_select_block u_note_select (
        .keys(keys),
        .divider_value(divider_value),
        .any_key(any_key_pressed),
        .note_num(note_num)
    );

//  *****************************Tone Generator************************************************
    logic audio_out;

    tone_generator_block u_tone_generator (
        .clk(max10_clk1_50),
        .enable(any_key_pressed),
        .divider_value(divider_value),
        .audio_out(audio_out)
    );

    // send audio signal to pin 7
    assign arduino_io[7] = audio_out;

//  *****************************HEX Display************************************************
    hex_display_block u_hex_display (
        .any_key(any_key_pressed),
        .note_num(note_num),
        .hex0(hex0),
        .hex1(hex1)
    );

//  *****************************LED Output************************************************
    always_comb begin
        ledr[6:0] = keys;
        ledr[9:7] = 3'b000;
    end
    endmodule

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

//  *****************************Tone Generator************************************************
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

//  *****************************HEX Display************************************************
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
