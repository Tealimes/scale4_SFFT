//By ALexander Peacock
//email: alexpeacock56ten@gmail.com
`ifndef uNSADD
`define uNSADD 

`include "parallelcnt.v"

module uNSADD #(
    parameter BINPUT = 2
    ) (
    input wire iClk, 
    input wire iRstN,
    input wire iA, 
    input wire iB, 
    output wire oC
);

    wire [BINPUT-1:0] PCout;
    wire [BINPUT:0] PCout_s;
    reg [9:0] acc_pc; //9 whole bits with one fractional bit
    reg [8:0] acc_off;
    reg [8:0] acc_out;
    reg [10:0] subOut; //msb is the sign bit
    wire [1:0] minOut;

    //Used to calculate the output
    parallelcnt u_parallelcnt (
        .iA(iA),
        .iB(iB),
        .PCout(PCout)
    );

    assign PCout_s[2:0] = {PCout[1:0], 1'b0}; //extends PCout with fraction

    //constantly accumulates it's own LSB with the PCout
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc_pc <= 0;
        end else if(acc_off == 9'b011111111) begin
            acc_pc <= 0;
        end else begin 
            acc_pc <= acc_pc + PCout_s;
        end
    end

    //constantly accumulates the offset
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc_off <= 0;
        end else if(acc_off == 9'b011111111) begin
            acc_off <= 0;
        end else begin
            acc_off <= acc_off + 1; //bipolar offset 0.5
        end
    end

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            subOut <= 0;
        end else if(acc_off == 9'b011111111)begin 
            subOut <= 0;
        end else begin 
            subOut <= acc_pc - acc_off;
        end
    end

    //tests if larger than past output accumulation
    assign minOut = {(subOut > acc_out) & ~(subOut[10] == 1), 1'b0};

    //constantly accumulates the output
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc_out <= 0;
        end else if(acc_off == 9'b011111111) begin
            acc_out <= 0;
        end else begin
            acc_out <= acc_out + minOut;
        end
    end

    //outputs the MSB of the accumulator 
    assign oC = minOut[1];

endmodule

`endif