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
    input logic [15:0] SW,             			// Switches para entrada de dígitos

	output logic guess_confirmed       			// Indica jogada confirmada
	output logic [2:0] cow_count,      			// Contagem de vacas
    output logic [2:0] bull_count,     			// Contagem de touros
    output logic [2:0] game_state,     			// Estado atual do jogo
    output logic [7:0] J1_points,      			// Pontos do J1
    output logic [7:0] J2_points,      			// Pontos do J2
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
	logic valid;                       			// Indica entrada válida
    state_t state;                     			// Estado atual
	logic [2:0] prev_state						// Estado anterior
    logic [3:0][3:0] numbers;          			// Entrada temporária de dígitos
    logic [3:0][3:0] magic_J1;         			// Número mágico de J1
    logic [3:0][3:0] magic_J2;         			// Número mágico de J2
    logic [3:0][3:0] J1_guessed;       			// Tentativa de J1
    logic [3:0][3:0] J2_guessed;       			// Tentativa de J2
    logic [2:0] reg_bull_count;        			// Contador de touros
    logic [2:0] reg_cow_count;         			// Contador de vacas
    logic guess_confirmed_reg;         			// Flag de jogada confirmada

    	// Saídas
    assign game_state = state;
    assign bull_count = reg_bull_count;
    assign cow_count = reg_cow_count;
    assign guess_confirmed = guess_confirmed_reg;

    	// Verifica se os números são diferentes e estão entre 0 e 9
    always_comb begin
        valid = (numbers[0] != numbers[1]) &&
                (numbers[0] != numbers[2]) &&
                (numbers[0] != numbers[3]) &&
                (numbers[1] != numbers[2]) &&
                (numbers[1] != numbers[3]) &&
                (numbers[2] != numbers[3]) &&
                (numbers[0] <= 4'd9) &&
                (numbers[1] <= 4'd9) &&
                (numbers[2] <= 4'd9) &&
                (numbers[3] <= 4'd9);
    end

    	// Lógica sequencial da máquina de estados
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= J1_SETUP;
            for (int i = 0; i < 4; i++) begin
                numbers[i] <= 4'b0;
                magic_J1[i] <= 4'b0;
                magic_J2[i] <= 4'b0;
                J1_guessed[i] <= 4'b0;
                J2_guessed[i] <= 4'b0;
            end
            reg_cow_count  <= 3'b0;
            reg_bull_count <= 3'b0;
            J1_points <= 8'b0;
            J2_points <= 8'b0;
            guess_confirmed_reg <= 1'b0;
        end else if (enter) begin
			prev_state <= state;
            case (state)
                J1_SETUP: begin
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
					guess_confirmed_reg <= 1'b0;
                    if (valid) begin
                        for (int i = 0; i < 4; i++) begin
                            magic_J1[i] <= numbers[i];
                        end
                        state <= J2_SETUP;
                    end
                end

                J2_SETUP: begin
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
					guess_confirmed_reg <= 1'b0;
                    if (valid) begin
                        for (int i = 0; i < 4; i++) begin
                            magic_J2[i] <= numbers[i];
                        end
                        state <= J1_GUESS;
                    end
                end

                J1_GUESS: begin
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
					reg_cow_count  <= 3'b0;
					reg_bull_count <= 3'b0;
                    if (valid) begin
                        for (int i = 0; i < 4; i++) begin
                            J1_guessed[i] <= numbers[i];
                        end
                        	// Conta os bulls
                        for (int i = 0; i < 4; i++) begin
                            if (numbers[i] == magic_J2[i]) begin
                                reg_bull_count <= reg_bull_count + 1;
                            end
                        end
                        	// Conta os cows
                        for (int i = 0; i < 4; i++) begin
                            if (numbers[i] != magic_J2[i]) begin
                                for (int j = 0; j < 4; j++) begin
                                    if ((numbers[i] == magic_J2[j]) && (i != j)) begin
                                        reg_cow_count <= reg_cow_count + 1;
                                        break; 	// Evita contagem dupla
                                    end
                                end
                            end
                        end
                        guess_confirmed_reg <= 1'b1;
                        if (reg_bull_count == 4) begin
                            state <= END_GAME;
                        end else begin
                            state <= J2_GUESS;
                        end
                    end
                end

                J2_GUESS: begin
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
					reg_cow_count  <= 3'b0;
					reg_bull_count <= 3'b0;
                    if (valid) begin
                        for (int i = 0; i < 4; i++) begin
                            J2_guessed[i] <= numbers[i];
                        end
                        	// Conta os bulls
                        for (int i = 0; i < 4; i++) begin
                            if (numbers[i] == magic_J1[i]) begin
                                reg_bull_count <= reg_bull_count + 1;
                            end
                        end
                        	// Conta os cows
                        for (int i = 0; i < 4; i++) begin
                            if (numbers[i] != magic_J1[i]) begin
                                for (int j = 0; j < 4; j++) begin
                                    if ((numbers[i] == magic_J1[j]) && (i != j)) begin
                                        reg_cow_count <= reg_cow_count + 1;
                                        break; 	// Evita contagem dupla
                                    end
                                end
                            end
                        end
                        guess_confirmed_reg <= 1'b1;
                        if (reg_bull_count == 4) begin
                            state <= END_GAME;
                        end else begin
                            state <= J1_GUESS;
                        end
                    end
                end

                END_GAME: begin
                    if (prev_state == J1_GUESS) begin
                        J1_points <= J1_points + 1;
                    end else if (prev_state == J2_GUESS) begin
                        J2_points <= J2_points + 1;
                    end
                    guess_confirmed_reg <= 1'b0;
                    state <= J1_SETUP;
                end

                default: begin
                    state <= J1_SETUP;
                end
            endcase
        end
    end

endmodule