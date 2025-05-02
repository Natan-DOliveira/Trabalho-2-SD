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

module game (
    input [3:0][3:0] numbers,
    input [3:0][3:0] guess,
    input reset,
    input clock,
    output points[1:0][7:0]
);
	//maquina de estados
typedef enum logic[2:0] {
	J1_SETUP = 3'b000,
	J2_SETUP = 3'b001,
	J1_GUESS = 3'b010,
	J2_GUESS = 3'b011,
	END_GAME = 3'b111
} state_t;

		//Registradores
	state_t state;
	 
	
