module BullCow_Game_Top (
    input logic clock,
    input logic reset,
    input logic enter,
    input logic SW[15:0],
    output logic LED[15:0],
    output logic segment[7:0],
    output logic display[7:0]
);

        // Sinais internos


        // Instacia os mõdulos
    BullCow_Game game_logic (
        .clock(clock),
        .reset(enter),
        .enter(enter),
        .SW(SW)
    );

    Game_Display game_display (
        .clock(clock),
        .reset(reset),
        .display(display),
        .segment(segment),
        ,LED(LED)
    );
