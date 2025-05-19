module Game_Display_LED
#(parameter HALF_MS_COUNT = 50000)              // 1 kHz com clock de 100 MHz 
(
    input logic clock,
    input logic reset,
    input logic J1_guess_confirmed,
    input logic J2_guess_confirmed,
    input logic [2:0] game_state,
	input logic [2:0] J1_cow_count,
    input logic [2:0] J2_cow_count,
    input logic [2:0] J1_bull_count,
    input logic [2:0] J2_bull_count,
    input logic [7:0] J1_points,
    input logic [7:0] J2_points,
    input logic [15:0] SW,

    output logic [7:0] AN,                      // Controle dos displays
    output logic [7:0] DDP,                     // Segmentos de a até dp
    output logic [15:0] LED                     // LEDs indicam a pontuação dos jogadores
);

        // Estados do jogo
    typedef enum logic[2:0] {
        J1_SETUP  = 3'b000,
        J2_SETUP  = 3'b001,
        J1_GUESS  = 3'b010,
        J2_GUESS  = 3'b011,
        END_GAME  = 3'b111
    } state_t;

        // Registradores
    reg ck_1KHz;                                // Clock de 1 kHz
    reg [2:0]  dig_selection;                   // Seleciona o display atual (0 a 7)
    reg [4:0]  selected_dig;                    // Digito selecionado
    reg [31:0] count_50k;                       // Contador para o 1 KHz
    // Entradas de dígitos
    reg [5:0] d1;
    reg [5:0] d2;
    reg [5:0] d3;
    reg [5:0] d4;
    reg [5:0] d5;
    reg [5:0] d6;
    reg [5:0] d7;
    reg [5:0] d8;


        // Geração do clock de 1 kHz
    always @(posedge clock or posedge reset) begin
        if (reset == 1'b1) begin
            ck_1KHz   <= 1'b0;
            count_50k <= 32'd0;
        end
        else begin
            if (count_50k == HALF_MS_COUNT - 1) begin
                ck_1KHz   <= ~ck_1KHz;
                count_50k <= 32'd0;
            end
            else begin
                count_50k <= count_50k + 1;
            end
        end
    end

        // Geração dos dígitos d1 até d8 pelo estado atual do jogo
    always_comb begin
        if (reset) begin
            LED = 16'b0;                        // Limpa os LEDs
        end
        else begin
                // LED[7:0] J1
            case (J1_points)
                8'd0:    LED[7:0] = 8'b00000000;
                8'd1:    LED[7:0] = 8'b10000000;
                8'd2:    LED[7:0] = 8'b11000000;
                8'd3:    LED[7:0] = 8'b11100000;
                8'd4:    LED[7:0] = 8'b11110000;
                8'd5:    LED[7:0] = 8'b11111000;
                8'd6:    LED[7:0] = 8'b11111100;
                8'd7:    LED[7:0] = 8'b11111110;
                default: LED[7:0] = 8'b11111111;
            endcase
                // LED[15:8] J2
            case (J2_points)
                8'd0:    LED[15:8] = 8'b00000000;
                8'd1:    LED[15:8] = 8'b00000001;
                8'd2:    LED[15:8] = 8'b00000011;
                8'd3:    LED[15:8] = 8'b00000111;
                8'd4:    LED[15:8] = 8'b00001111;
                8'd5:    LED[15:8] = 8'b00011111;
                8'd6:    LED[15:8] = 8'b00111111;
                8'd7:    LED[15:8] = 8'b01111111;
                default: LED[15:8] = 8'b11111111;
            endcase
        end
    end

        // Geração dos dígitos d1 até d8 pelo estado atual do jogo
    always_comb begin
            // [5] = enable, [4:1] = char, [0] = dp
        d1 = 6'b0;
        d2 = 6'b0;
        d3 = 6'b0;
        d4 = 6'b0;
        d5 = 6'b0;
        d6 = 6'b0;
        d7 = 6'b0;
        d8 = 6'b0;

        case (game_state) 
            J1_SETUP: begin
                /*
                    // display -> "J1 SETUP"
                d8 = {1'b1, 4'h6, 1'b1};        // J
                d7 = {1'b1, 4'h1, 1'b1};        // 1
                d6 =  6'b0;                     // espaço
                d5 = {1'b1, 4'hC, 1'b1};        // S
                d4 = {1'b1, 4'hE, 1'b1};        // E
                d3 = {1'b1, 4'hD, 1'b1};        // T
                d2 = {1'b1, 4'hF, 1'b1};        // U
                d1 = {1'b1, 4'h9, 1'b1};        // P
                */
                    // display -> "J1 XXYY" (XXYY são os 4 dígitos dos switches)
                d8 = {1'b1, 4'h6, 1'b1};        // J
                d7 = {1'b1, 4'h1, 1'b1};        // 1
                d6 = 6'b0;                      // espaço
                d5 = {1'b1, SW[15:12], 1'b0};   // Digito 1
                d4 = {1'b1, SW[11:8], 1'b0};    // Digito 2
                d3 = {1'b1, SW[7:4], 1'b0};     // Digito 3
                d2 = {1'b1, SW[3:0], 1'b0};     // Digito 4
                d1 = 6'b0;                      // espaço
            end
            
            J2_SETUP: begin
                /*
                    // display -> "J2 SETUP"
                d8 = {1'b1, 4'h6, 1'b0};        // J
                d7 = {1'b1, 4'h2, 1'b0};        // 2
                d6 =  6'b0;                     // espaço
                d5 = {1'b1, 4'hC, 1'b0};        // S
                d4 = {1'b1, 4'hE, 1'b0};        // E
                d3 = {1'b1, 4'hD, 1'b0};        // T
                d2 = {1'b1, 4'hF, 1'b0};        // U
                d1 = {1'b1, 4'h9, 1'b0};        // P
                */
                    // display -> "J2 XXYY" (XXYY são os 4 dígitos dos switches)
                d8 = {1'b1, 4'h6, 1'b0};        // J
                d7 = {1'b1, 4'h2, 1'b0};        // 2
                d6 = 6'b0;                      // espaço
                d5 = {1'b1, SW[15:12], 1'b0};   // Digito 1
                d4 = {1'b1, SW[11:8], 1'b0};    // Digito 2
                d3 = {1'b1, SW[7:4], 1'b0};     // Digito 3
                d2 = {1'b1, SW[3:0], 1'b0};     // Digito 4
                d1 = 6'b0;                      // espaço
            end

            J1_GUESS: begin
                if (J1_guess_confirmed) begin
                        // display -> "X TO Y VA" | X: número de bulls | Y: número de cows
                    d8 = {1'b1, (J1_bull_count > 4'd4 ? 4'd0 : J1_bull_count), 1'b1};// X
                    d7 = 6'b0;                                  // espaço
                    d6 = {1'b1, 4'hD, 1'b1};                    // T
                    d5 = {1'b1, 4'h0, 1'b1};                    // O
                    d4 = 6'b0;                                  // espaço
                    d3 = {1'b1, (J1_cow_count > 4'd4 ? 4'd0 : J1_cow_count), 1'b1};// Y
                    d2 = {1'b1, 4'hF, 1'b1};                    // V
                    d1 = {1'b1, 4'hA, 1'b1};                    // A
                end
                else begin
                        // display -> "J1 GUESS"
                    d8 = {1'b1, 4'h6, 1'b1};        // J
                    d7 = {1'b1, 4'h1, 1'b1};        // 1
                    d6 =  6'b0;                     // espaço
                    d5 = {1'b1, 4'h5, 1'b1};        // G
                    d4 = {1'b1, 4'hF, 1'b1};        // U
                    d3 = {1'b1, 4'hE, 1'b1};        // E
                    d2 = {1'b1, 4'hC, 1'b1};        // S
                    d1 = {1'b1, 4'hC, 1'b1};        // S
                end
            end

            J2_GUESS: begin
                if (J2_guess_confirmed) begin
                        // display -> "X TO Y VA" | X: número de bulls | Y: número de cows
                    d8 = {1'b1, (J2_bull_count > 4'd4 ? 4'd0 : J2_bull_count), 1'b0};      // X
                    d7 = 6'b0;                                  // espaço
                    d6 = {1'b1, 4'hD, 1'b0};                    // T
                    d5 = {1'b1, 4'h0, 1'b0};                    // O
                    d4 = 6'b0;                                  // espaço
                    d3 = {1'b1, (J2_cow_count > 4'd4 ? 4'd0 : J2_cow_count), 1'b0};       // Y
                    d2 = {1'b1, 4'hF, 1'b0};                    // V
                    d1 = {1'b1, 4'hA, 1'b0};                    // A
                end
                else begin
                        // display -> "J2 GUESS"
                    d8 = {1'b1, 4'h6, 1'b0};        // J
                    d7 = {1'b1, 4'h2, 1'b0};        // 2
                    d6 =  6'b0;                     // espaço
                    d5 = {1'b1, 4'h5, 1'b0};        // G
                    d4 = {1'b1, 4'hF, 1'b0};        // U
                    d3 = {1'b1, 4'hE, 1'b0};        // E
                    d2 = {1'b1, 4'hC, 1'b0};        // S
                    d1 = {1'b1, 4'hC, 1'b0};        // S
                end
            end

            END_GAME: begin
                    // display -> "BULLSEYE"
                d8 = {1'b1, 4'hB, 1'b1};            // B
                d7 = {1'b1, 4'hF, 1'b1};            // U
                d6 = {1'b1, 4'h7, 1'b1};            // L
                d5 = {1'b1, 4'h7, 1'b1};            // L
                d4 = {1'b1, 4'hC, 1'b1};            // S
                d3 = {1'b1, 4'hE, 1'b1};            // E
                d2 = {1'b1, 4'h8, 1'b1};            // Y
                d1 = {1'b1, 4'hE, 1'b1};            // E
            end
            default: begin
                d1 = 6'b0;
                d2 = 6'b0;
                d3 = 6'b0;
                d4 = 6'b0;
                d5 = 6'b0;
                d6 = 6'b0;
                d7 = 6'b0;
                d8 = 6'b0;
            end
        endcase
    end

        // Contador que seleciona o display e atualiza AN/selected_dig
    always @(posedge ck_1KHz or posedge reset) begin
        if (reset) begin
            dig_selection <= 3'd0;
            selected_dig  <= 5'd0;
            AN            <= 8'b11111111;
        end
        else begin
            if (dig_selection == 3'b111) begin
                dig_selection <= 3'd0;
            end
            else begin
                dig_selection <= dig_selection + 1;
            end
            
            case (dig_selection)
                3'd0: begin
                    selected_dig <= d1[4:0];
                    AN <= {7'b1111111, ~d1[5]};
                end
                
                3'd1: begin
                    selected_dig <= d2[4:0];
                    AN <= {6'b111111, ~d2[5], 1'b1};
                end
        
                3'd2: begin
                    selected_dig <= d3[4:0];
                    AN <= {5'b11111, ~d3[5], 2'b11};
                end
                
                3'd3: begin
                    selected_dig <= d4[4:0];
                    AN <= {4'b1111, ~d4[5], 3'b111};
                end
                
                3'd4: begin
                    selected_dig <= d5[4:0];
                    AN <= {3'b111, ~d5[5], 4'b1111};
                end
                
                3'd5: begin
                    selected_dig <= d6[4:0];
                    AN <= {2'b11, ~d6[5], 5'b11111};
                end
        
                3'd6: begin
                    selected_dig <= d7[4:0];
                    AN <= {1'b1, ~d7[5], 6'b111111};
                end
        
                default: begin
                    selected_dig <= d8[4:0];
                    AN <= {~d8[5], 7'b1111111};
                end
            endcase
        end
    end
    
    always @*
    begin
        case (selected_dig[4:1])
            4'h0:    DDP[7:1] = 7'b0000001;        // 0
            4'h1:    DDP[7:1] = 7'b1001111;        // 1
            4'h2:    DDP[7:1] = 7'b0010010;        // 2
            4'h3:    DDP[7:1] = 7'b0000110;        // 3
            4'h4:    DDP[7:1] = 7'b1001100;        // 4
            4'h5:    DDP[7:1] = 7'b0100001;        // G
            4'h6:    DDP[7:1] = 7'b0000011;        // J
            4'h7:    DDP[7:1] = 7'b1110001;        // L
            4'h8:    DDP[7:1] = 7'b1001100;        // Y
            4'h9:    DDP[7:1] = 7'b0011000;        // P
            4'hA:    DDP[7:1] = 7'b0001000;        // A
            4'hB:    DDP[7:1] = 7'b1100000;        // B
            4'hC:    DDP[7:1] = 7'b0100100;        // S
            4'hD:    DDP[7:1] = 7'b1110000;        // T
            4'hE:    DDP[7:1] = 7'b0110000;        // E 
            4'hF:    DDP[7:1] = 7'b1000001;        // U e V
            default: DDP[7:1] = 7'b1111111;        // apagado
        endcase
        DDP[0] = selected_dig[0];
    end
endmodule
