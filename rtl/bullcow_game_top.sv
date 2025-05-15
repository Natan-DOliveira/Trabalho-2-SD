module BullCow_Game_Top (
    input logic clock,
    input logic reset,
    input logic enter,
    input logic [15:0] SW,

    output logic [7:0] AN,
    output logic [7:0] DDP,
    output logic [15:0] LED
);
        // Sinais internos
    logic guess_confirmed;
    logic [2:0] cow_count;
    logic [2:0] bull_count;
	logic [2:0] game_state;
    logic [7:0] J1_points;
    logic [7:0] J2_points;

        // Instacia os módulos
    BullCow_Game game_logic (
        .clock(clock),
        .reset(reset),
        .enter(enter),
        .SW(SW),
        .J1_points(J1_points),
        .J2_points(J2_points),
        .cow_count(cow_count),
        .bull_count(bull_count),
        .game_state(game_state),
        .guess_confirmed(guess_confirmed)
    );
    Game_Display_LED game_display (
        .clock(clock),
        .reset(reset),
        .AN(AN),
        .DDP(DDP),
        .LED(LED),
        .J1_points(J1_points),
        .J2_points(J2_points),
        .cow_count(cow_count),
        .bull_count(bull_count),
        .game_state(game_state),
        .guess_confirmed(guess_confirmed)
    );
endmodule