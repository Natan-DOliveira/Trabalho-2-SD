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
