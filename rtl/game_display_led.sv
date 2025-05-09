module Game_Display_LED (
    input logic clock,
    input logic reset,
    input logic [7:0] J1_points,
    input logic [7:0] J2_points,
    input logic [2:0] bull_count,
    input logic [2:0] cow_count,
    input logic [2:0] game_state,

    output logic [7:0] AN,
    output logic [7:0] DDP,
    output logic [15:0] LED
);
        // Lógica combinacional para os LEDs
    always_comb begin
            
            // LED[7:0] J1
        case (J1_points)
            8'd0:    LED[7:0] = 8'b00000000;
            8'd1:    LED[7:0] = 8'b00000001;
            8'd2:    LED[7:0] = 8'b00000011;
            8'd3:    LED[7:0] = 8'b00000111;
            8'd4:    LED[7:0] = 8'b00001111;
            8'd5:    LED[7:0] = 8'b00011111;
            8'd6:    LED[7:0] = 8'b00111111;
            8'd7:    LED[7:0] = 8'b01111111;
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

        // Lógica síncrona de reset
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            LED <= 16'b0;                       // Limpa os LEDs
        end
    end

endmodule