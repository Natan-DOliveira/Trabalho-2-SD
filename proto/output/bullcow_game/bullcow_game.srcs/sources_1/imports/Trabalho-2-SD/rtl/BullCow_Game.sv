/*
LER SEGREDO1:
-número válido = próxima etapa
-número inválido = repete LER SEGREDO1

LER SEGREDO2:
-número válido = próxima etapa
-número inválido = repete LER SEGREDO2

ADIVINHA SEGREDO1:
-número válido:
	acertou o número = fim de jogo
	errou o número = próximo passo ADIVINHA SEGREDO2
-número inválido = repete ADIVINHA SEGREDO1

ADIVINHA SEGREDO2:
-número válido:
	acertou o número = fim de jogo
	errou o número = próximo passo ADIVINHA SEGREDO1
-número inválido = repete ADIVINHA SEGREDO2

FIM DE JOGO:
-contabiliza vitória de um dos jogadores e volta para LER SEGREDO1
*/

module BullCow_Game (
    input logic clock,
    input logic reset,
    input logic enter,
    input logic [15:0] SW,                      // Switches para entrada de dígitos

    output logic J1_win,                        // Indica vitoria do J1
    output logic J2_win,                        // Indica vitoria do J2
    output logic J1_guess_confirmed,            // Indica jogada confirmada do J1
    output logic J2_guess_confirmed,            // Indica jogada confirmada do J2
    output logic [2:0] game_state,              // Estado atual do jogo
    output logic [2:0] J1_cow_count,            // Contagem de vacas do J1
    output logic [2:0] J2_cow_count,            // Contagem de vacas do J2
    output logic [2:0] J1_bull_count,           // Contagem de touros do J1
    output logic [2:0] J2_bull_count,           // Contagem de touros do J2
    output logic [2:0] game_prev_state,         // Estado anterior do jogo
    output logic [7:0] J1_points,               // Pontos do J1
    output logic [7:0] J2_points                // Pontos do J2
);

        // Definição dos estados
    typedef enum logic[2:0] {
        J1_SETUP  = 3'b000,
        J2_SETUP  = 3'b001,
        J1_GUESS  = 3'b010,
        J2_GUESS  = 3'b011,
        END_GAME  = 3'b111
    } state_t;

        // Registradores
    state_t state;                      // Estado atual
    state_t prev_state;                 // Estado anterior
    logic valid;                        // Indica entrada válida
    logic prev_enter;                   // Valor anterior do enter
    logic reg_J1_win;                   // Flag p/ confirmação da vitoria do J1
    logic reg_J2_win;                   // Flag p/ confirmação da vitoria do J2
    logic reg_J1_guess_confirmed;       // Flag p/ confirmação da tentativa do J1
    logic reg_J2_guess_confirmed;       // Flag p/ confirmação da tentativa do J2
    logic [2:0] reg_J1_cow_count;       // Contador de vacas do J1
    logic [2:0] reg_J2_cow_count;       // Contador de vacas do J2
    logic [2:0] reg_J1_bull_count;      // Contador de touros do J1
    logic [2:0] reg_J2_bull_count;      // Contador de touros do J2
    logic [3:0] J1_used;
    logic [3:0] J2_used;
    logic [3:0][3:0] magic_J1;          // Número mágico do J1
    logic [3:0][3:0] magic_J2;          // Número mágico do J2
    logic [31:0] delay_counter;         // Contador para delay em END_GAME

        // Sinais combinacionais para contagem
    logic [2:0] J1_cow_count_comb;
    logic [2:0] J1_bull_count_comb;
    logic [2:0] J2_bull_count_comb;
    logic [2:0] J2_cow_count_comb;

        // Saídas
    assign game_state         = state;
    assign game_prev_state    = prev_state;
    assign J1_win             = reg_J1_win;
    assign J2_win             = reg_J2_win;
    assign J1_cow_count       = reg_J1_cow_count;
    assign J2_cow_count       = reg_J2_cow_count;
    assign J1_bull_count      = reg_J1_bull_count;
    assign J2_bull_count      = reg_J2_bull_count;
    assign J1_guess_confirmed = reg_J1_guess_confirmed;
    assign J2_guess_confirmed = reg_J2_guess_confirmed;

    // Verifica se os números são diferentes e estão entre 0 e 7
    always_comb begin
        valid = (SW[3:0]   != SW[7:4])   &&
                (SW[3:0]   != SW[11:8])  &&
                (SW[3:0]   != SW[15:12]) &&
                (SW[7:4]   != SW[11:8])  &&
                (SW[7:4]   != SW[15:12]) &&
                (SW[11:8]  != SW[15:12]) &&
                (SW[3:0]   <= 4'd9)      &&
                (SW[7:4]   <= 4'd9)      &&
                (SW[11:8]  <= 4'd9)      &&
                (SW[15:12] <= 4'd9);
    end

        // Lógica combinacional para contagem de bulls e cows
    always_comb begin
            // Inicialização
        J1_cow_count_comb  = 3'b0;
        J1_bull_count_comb = 3'b0;
        J2_cow_count_comb  = 3'b0;
        J2_bull_count_comb = 3'b0;
        begin : J1_count
            J1_used = 4'b0000;
                // Conta os bulls para J1
            for (int i = 0; i < 4; i++) begin
                if (SW[(3-i)*4 +: 4] == magic_J2[i]) begin
                    J1_bull_count_comb = J1_bull_count_comb + 1;
                end
            end
                // Conta os cows para J1
            for (int i = 0; i < 4; i++) begin
                if (SW[(3-i)*4 +: 4] != magic_J2[i]) begin
                    for (int j = 0; j < 4; j++) begin
                        if ((SW[(3-i)*4 +: 4] == magic_J2[j]) && (i != j) && !J1_used[j]) begin
                            J1_used[j]        = 1'b1;
                            J1_cow_count_comb = J1_cow_count_comb + 1;
                        end
                    end
                end
            end
        end
        begin : J2_count
            J2_used = 4'b0000;
                // Conta os bulls para J2
            for (int i = 0; i < 4; i++) begin
                if (SW[(3-i)*4 +: 4] == magic_J1[i]) begin
                    J2_bull_count_comb = J2_bull_count_comb + 1;
                end
            end
                // Conta os cows para J2
            for (int i = 0; i < 4; i++) begin
                if (SW[(3-i)*4 +: 4] != magic_J1[i]) begin
                    for (int j = 0; j < 4; j++) begin
                        if ((SW[(3-i)*4 +: 4] == magic_J1[j]) && (i != j) && !J2_used[j]) begin
                            J2_used[j]        = 1'b1;
                            J2_cow_count_comb = J2_cow_count_comb + 1; 
                        end
                    end
                end
            end
        end
    end

        // Lógica sequencial da máquina de estados
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= J1_SETUP;
            for (int i = 0; i < 4; i++) begin
                magic_J1[i] <= 4'b0;
                magic_J2[i] <= 4'b0;
            end
            J1_points              <= 8'b0;
            J2_points              <= 8'b0;
            prev_enter             <= 1'b0;
            prev_state             <= J1_SETUP;
            reg_J1_win             <= 1'b0;
            reg_J2_win             <= 1'b0;
            reg_J1_cow_count       <= 3'b0;
            reg_J2_cow_count       <= 3'b0;
            reg_J1_bull_count      <= 3'b0;
            reg_J2_bull_count      <= 3'b0;
            reg_J1_guess_confirmed <= 1'b0;
            reg_J2_guess_confirmed <= 1'b0;
        end
        else if (enter == 1 && prev_enter == 0) begin
            prev_state <= state;
            case (state)
                J1_SETUP: begin
                    if (valid) begin
                        magic_J1[0] <= SW[15:12];
                        magic_J1[1] <= SW[11:8];
                        magic_J1[2] <= SW[7:4];
                        magic_J1[3] <= SW[3:0];
                        state <= J2_SETUP;
                    end
                end

                J2_SETUP: begin
                    if (valid) begin
                        magic_J2[0] <= SW[15:12];
                        magic_J2[1] <= SW[11:8];
                        magic_J2[2] <= SW[7:4];
                        magic_J2[3] <= SW[3:0];
                        state <= J1_GUESS;
                    end
                end

                J1_GUESS: begin
                    if (!reg_J1_guess_confirmed) begin
                        if (valid) begin
                            reg_J1_cow_count  <= J1_cow_count_comb;
                            reg_J1_bull_count <= J1_bull_count_comb;
                            if (J1_bull_count_comb == 4) begin
                                state <= END_GAME;
                            end
                            else begin
                                reg_J1_guess_confirmed <= 1'b1;
                            end
                        end
                    end
                    else begin
                        state <= J2_GUESS;
                        reg_J1_guess_confirmed <= 1'b0;
                    end
                end

                J2_GUESS: begin
                    if (!reg_J2_guess_confirmed) begin
                        if (valid) begin
                            reg_J2_cow_count  <= J2_cow_count_comb;
                            reg_J2_bull_count <= J2_bull_count_comb;
                            if (J2_bull_count_comb == 4) begin
                                state <= END_GAME;
                            end
                            else begin
                                reg_J2_guess_confirmed <= 1'b1;
                            end
                        end
                    end
                    else begin
                        state <= J1_GUESS;
                        reg_J2_guess_confirmed <= 1'b0;
                    end
                end

                END_GAME: begin
                    if (prev_state == J1_GUESS) begin
                        J1_points  <= J1_points + 1;
                        if (J1_points + 1 == 8) begin
                            reg_J1_win <= 1'b1;
                        end
                    end 
                    else if (prev_state == J2_GUESS) begin
                        J2_points  <= J2_points + 1;
                        if (J2_points + 1 == 8) begin
                            reg_J2_win <= 1'b1;
                        end
                    end
                    else begin
                        if (reg_J1_win || reg_J2_win) begin
                            J1_points <= 8'b0;
                            J2_points <= 8'b0;
                        end
                        state      <= J1_SETUP;
                        reg_J1_win <= 1'b0;
                        reg_J2_win <= 1'b0;
                    end
                end

                default: begin
                    state <= J1_SETUP;
                end
            endcase
        end
        prev_enter <= enter;
    end
endmodule