// device: xc7a100tcsg324-1
module top_BullCow_Game_NexysA7 (
    input logic clock,
    input logic reset,
    input logic enter,
    input logic [15:0] SW,

    output logic [7:0] AN,
    output logic [7:0] DDP,
    output logic [15:0] LED
);
        // Sinais internos
    logic J1_win;
    logic J2_win;
    logic J1_guess_confirmed;
    logic J2_guess_confirmed;
    logic [2:0] game_state;
	logic [2:0] J1_cow_count;
    logic [2:0] J2_cow_count;      		
    logic [2:0] J1_bull_count;     		
    logic [2:0] J2_bull_count;
    logic [2:0] game_prev_state;		
    logic [7:0] J1_points;
    logic [7:0] J2_points;

        // Instacia os módulos
    BullCow_Game game_logic (
        .SW(SW),
        .clock(clock),
        .reset(reset),
        .enter(enter),
        .J1_win(J1_win),
        .J2_win(J2_win),
        .J1_points(J1_points),
        .J2_points(J2_points),
        .game_state(game_state),
        .J1_cow_count(J1_cow_count),
        .J2_cow_count(J2_cow_count),
        .J1_bull_count(J1_bull_count),
        .J2_bull_count(J2_bull_count),
        .game_prev_state(game_prev_state),
        .J1_guess_confirmed(J1_guess_confirmed),
        .J2_guess_confirmed(J2_guess_confirmed)
    );
    
    Game_Display_LED game_display (
        .AN(AN),
        .DDP(DDP),
        .LED(LED),
        .clock(clock),
        .reset(reset),
        .J1_win(J1_win),
        .J2_win(J2_win),
        .J1_points(J1_points),
        .J2_points(J2_points),
        .game_state(game_state),
        .J1_cow_count(J1_cow_count),
        .J2_cow_count(J2_cow_count),
        .J1_bull_count(J1_bull_count),
        .J2_bull_count(J2_bull_count),
        .game_prev_state(game_prev_state),
        .J1_guess_confirmed(J1_guess_confirmed),
        .J2_guess_confirmed(J2_guess_confirmed)
    );
endmodule