//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com
`ifndef uSSUB
`define uSSUB

`include "parallelcnt.v"

module uSSUB #(
    parameter BINPUT = 2
) (
    input wire iClk,
    input wire iRstN, 
    input wire iA,
    input wire iB,
    output wire oC
);

    wire [BINPUT-1:0] PCout;
    reg [1:0] acc;

    //Used to calculate the output
    //one stream inverted to represent subtraction
    parallelcnt u_parallelcnt (
        .iA(iA),
        .iB(~iB),
        .PCout(PCout)
    );

    //constantly accumulates it's own LSB with the PCout
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc <= 0;
        end else begin
            acc <= acc[0] + PCout;
        end
    end

    //outputs the MSB of the accumulator 
    assign oC = acc[1];

endmodule

`endif


