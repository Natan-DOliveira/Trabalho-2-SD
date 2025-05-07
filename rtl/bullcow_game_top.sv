module Bullcow_Game_Top (
    input logic clock,
    input logic reset,
    input logic enter,
    input logic segment[7:0],
    input logic display[7:0],
    input logic SW[15:0],
    input logic LED[15:0]
);
