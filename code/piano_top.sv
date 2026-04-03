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
