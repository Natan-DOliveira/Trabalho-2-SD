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
    input logic reset,
    input logic clock,
    input logic enter,
    input logic [15:0] SW,

	output logic [2:0] bull_count,
	output logic [2:0] cow_count,
	output logic [2:0] game_state,
    output logic [7:0] J1_points,
	output logic [7:0] J2_points
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
    state_t state;
	logic [3:0][3:0] numbers; 
	logic [3:0][3:0] magic_J1; 					// números do J1
	logic [3:0][3:0] magic_J2; 					// números do J2
	logic [3:0][3:0] J1_guessed;
	logic [3:0][3:0] J2_guessed;
	logic valid;
	logic [2:0] reg_bull_count;
	logic [2:0] reg_cow_count;

		// Output do estado & bull_count e cow_count
	assing game_state = state;
	assing bull_count = reg_bull_count;
	assing cow_count  = reg_cow_count;

    	// Verifica se os números de J1 são diferentes
    always_comb begin
        valid = (numbers[0] != numbers[1]) &&
                (numbers[0] != numbers[2]) &&
                (numbers[0] != numbers[3]) &&
                (numbers[1] != numbers[2]) &&
                (numbers[1] != numbers[3]) &&
                (numbers[2] != numbers[3]);
    end

    	// Lógica sequencial da máquina de estados
	always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= J1_SETUP;
			for (int i = 0; i < 4; i++) begin
				numbers[i]  <= 4'b0;
				magic_J1[i] <= 4'b0;
				magic_J2[i] <= 4'b0;
				J1_guessed  <= 4'b0;
				J2_guessed  <= 4'b0;
			end 
            bull_count_reg <= 3'b0;
            cow_count_reg  <= 3'b0;
            win_J1 <= 8'b0;
            win_J2 <= 8'b0;
			J1_points <= 8'b0;
			J2_points <= 8'b0;
        end else if (enter) begin
            case (state)
                J1_SETUP: begin
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
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
                    if (valid) begin
						for (int i = 0; i < 4; i++) begin
							magic_J2[i] <= numbers[i];
						end
                        state <= J1_GUESS;
					end
                end

		    	J1_GUESS: begin
					reg_bull_count <= 4'b0;
					reg_cow_count <= 4'b0;
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
					if (valid) begin
						for (int i = 0; i < 4; i++) begin
							J1_guessed[i] <= numbers[i];	
						end
							// Conta os 'bulls'
						for (int i = 0; i < 4; i++) begin
							if (J1_guessed[i] == magic_J2[i]) begin
        						reg_bull_count <= reg_bull_count + 1;
    						end
						end
							// Se acertou todos, vence
						if (bull_count == 4) begin
    						J1_points <= J1_points + 1;
    						state <= END_GAME;
						end else begin
    							// Conta os 'cows' (números certos em posições erradas)
    						for (int i = 0; i < 4; i++) begin
								if (J1_guessed[i] != magic_J2[i]) begin
            						for (int j = 0; j < 4; j++) begin
										if ((J1_guessed[i] == magic_J2[j]) && (i != j)) begin
                    						reg_cow_count <= reg_cow_count + 1;
                    						break; // evita múltiplas contagens do mesmo
                						end
            						end
     							end
   							end
						end
				    	state <= J2_GUESS;
					end
                end

		    	J2_GUESS: begin
					reg_bull_count <= 4'b0;
					reg_cow_count  <= 4'b0;
			        numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
			    
		    		if (valid) begin
						for (int i = 0; i < 4; i++) begin
							J2_guessed[i] <= numbers[i];
						end
							// Conta os 'bulls'
						for (int i = 0; i < 4; i++) begin
    						if (J2_guessed[i] == magic_J1[i]) begin
        						reg_bull_count <= reg_bull_count + 1;
    						end
						end
							// Se acertou todos, vence
						if (bull_count == 4) begin
    						J2_points <= J2_points + 1;
    						state <= END_GAME;
						end else begin
    							// Conta os 'cows' (números certos em posições erradas)
    						for (int i = 0; i < 4; i++) begin
        						if (J2_guessed[i] != magic_J1[i]) begin
            						for (int j = 0; j < 4; j++) begin
                						if ((J2_guessed[i] == magic_J1[j]) && (i != j)) begin
                    						reg_cow_count <= reg_cow_count + 1;
                    						break; // evita múltiplas contagens do mesmo
                						end
            						end
        						end
                			end
						end
				    	state <= J1_GUESS;
     				end
				end

		    	END_GAME: begin
					state <= J1_SETUP;
		    	end
                
				default: begin
					state <= state;
				end
            endcase
        end
    end
endmodule

			
