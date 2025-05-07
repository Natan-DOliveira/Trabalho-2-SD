module Bullcow_Game_Top (
    input logic clock,
    input logic reset,
    input logic enter,
    input logic SW[15:0],
    output logic LED[15:0],
    output logic segment[7:0],
    output logic display[7:0]
);



