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
    input logic [3:0][3:0] guess,
    input logic [15:0] SW,
    output logic [15:0] LED,
    output logic [1:0][7:0] points
);

    typedef enum logic[2:0] {
        J1_SETUP  = 3'b000,
        J2_SETUP  = 3'b001,
        J1_GUESS  = 3'b010,
        J2_GUESS  = 3'b011,
        END_GAME  = 3'b111
    } state_t;

    state_t state;

	logic [3:0] numbers [3:0]; 
	logic [3:0] magic_J1 [3:0]; // números do J1
	logic [3:0] magic_J2 [3:0]; // números do J2
	logic [3:0] J1_guessed [3:0];
	logic [3:0] J2_guessed [3:0];
	logic valid;
	int bull_count;
	int cow_count;
	int win_J1;
	int win_J2;

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
            numbers[0] <= 4'b0;
            numbers[1] <= 4'b0;
            numbers[2] <= 4'b0;
            numbers[3] <= 4'b0;
            LED <= 16'b0;
            points[0] <= 8'b0;
            points[1] <= 8'b0;
	    bull_count = 0;
	    cow_count = 0;
	    win_J2 = 0;
	    win_J1 = 0;
        end else begin
            case (state)
                J1_SETUP: begin
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
                    
                    if (valid)
			magic_J1[0] <= numbers[0];
			magic_J1[1] <= numbers[1];
			magic_J1[2] <= numbers[2];
			magic_J1[3] <= numbers[3];

                        state <= J2_SETUP;
			
                    else begin
                        // limpa números se inválido
                        numbers[0] <= 4'b0;
                        numbers[1] <= 4'b0;
                        numbers[2] <= 4'b0;
                        numbers[3] <= 4'b0;
                        state <= J1_SETUP; // permanece no setup
                    end
                end

                J2_SETUP: begin
	            numbers[0] <= 4'b0;
                    numbers[1] <= 4'b0;
                    numbers[2] <= 4'b0;
                    numbers[3] <= 4'b0;
			
                    numbers[0] <= SW[3:0];
                    numbers[1] <= SW[7:4];
                    numbers[2] <= SW[11:8];
                    numbers[3] <= SW[15:12];
                    
                    if (valid)
			magic_J2[0] <= numbers[0];
			magic_J2[1] <= numbers[1];
			magic_J2[2] <= numbers[2];
			magic_J2[3] <= numbers[3];

                        state <= J1_GUESS;
                    else begin
                        state <= J2_SETUP; // permanece no setup
                    end
                end
		    J1_GUESS: begin
			bull_count <= 0;
			cow_count <= 0;
			numbers[0] <= 4'b0;
                    	numbers[1] <= 4'b0;
                    	numbers[2] <= 4'b0;
                    	numbers[3] <= 4'b0;
			
                    	numbers[0] <= SW[3:0];
                    	numbers[1] <= SW[7:4];
                    	numbers[2] <= SW[11:8];
                    	numbers[3] <= SW[15:12];
			    
		    if (valid)
			J1_guessed[0] <= numbers[0];
			J1_guessed[1] <= numbers[1];
			J1_guessed[2] <= numbers[2];
			J1_guessed[3] <= numbers[3];

		for (int i = 0; i < 4; i++) begin
			if (J1_guessed[i] == magic_J2[i]) begin
        			bull_count++;
    			end
		end

		// Se acertou todos, vence
		if (bull_count == 4) begin
    			win_J1++;
    			state <= END_GAME;
		end else begin
			
    		// Conta os 'cows' (números certos em posições erradas)
    		for (int i = 0; i < 4; i++) begin
			if (J1_guessed[i] != magic_J2[i]) begin
            			for (int j = 0; j < 4; j++) begin
					if ((J1_guessed[i] == magic_J2[j]) && (i != j)) begin
                    				cow_count++;
                    			break; // evita múltiplas contagens do mesmo
                		end
            		end
     		end
   	end
end

				    state <= J2_GUESS;
	end
                    else begin
                        state <= J1_GUESS; // permanece no setup
                    end
                end

		    J2_GUESS: begin
			bull_count <= 0;
			cow_count <= 0;
			numbers[0] <= 4'b0;
                    	numbers[1] <= 4'b0;
                    	numbers[2] <= 4'b0;
                    	numbers[3] <= 4'b0;
			
                    	numbers[0] <= SW[3:0];
                    	numbers[1] <= SW[7:4];
                    	numbers[2] <= SW[11:8];
                    	numbers[3] <= SW[15:12];
			    
		    if (valid)
			J2_guessed[0] <= numbers[0];
			J2_guessed[1] <= numbers[1];
			J2_guessed[2] <= numbers[2];
			J2_guessed[3] <= numbers[3];

			// Primeiro, conta os 'bulls'
			for (int i = 0; i < 4; i++) begin
    				if (J2_guessed[i] == magic_J1[i]) begin
        				bull_count++;
    				end
			end

			// Se acertou todos, vence
			if (bull_count == 4) begin
    				win_J2++;
    				state <= END_GAME;
			end else begin
				
    			// Conta os 'cows' (números certos em posições erradas)
    			for (int i = 0; i < 4; i++) begin
        			if (J2_guessed[i] != magic_J1[i]) begin
            				for (int j = 0; j < 4; j++) begin
                				if ((J2_guessed[i] == magic_J1[j]) && (i != j)) begin
                    					cow_count++;
                    				break; // evita múltiplas contagens do mesmo
                			end
            			end
        		end
                end
	end

				    state <= J1_GUESS;
     end
                    else begin
                        state <= J2_GUESS; // permanece no setup
                    end
                end

		    END_GAME: begin
			
		    end
                default: state <= state;
            endcase
        end
    end

endmodule

			
