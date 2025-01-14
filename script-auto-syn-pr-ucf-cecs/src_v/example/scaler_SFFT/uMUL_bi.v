//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com
`ifndef uMUL_bi
`define uMUL_bi

`include "sobolrng.v"

module uMUL_bi #(
    parameter BITWIDTH = 8
) (
    input wire iClk,
    input wire iRstN,
    input wire iEn,
    input wire iA,
    input wire [BITWIDTH - 1: 0] iB,
    input wire loadB,
    input wire iClr,
    output reg oB,
    output reg oMult
);

    reg [BITWIDTH-1:0] iB_buff; //to store a value in block
    wire [BITWIDTH-1:0] sobolseqIn;
    wire [BITWIDTH-1:0] sobolseq;
    wire [BITWIDTH-1:0] sobolseqRan;
    wire andTop;
    wire andBot;
    wire iA_inv = ~iA;

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            iB_buff <= 0;
        end else begin
            if(iEn) begin
                if(loadB) begin
                    iB_buff <= iB;
                end else begin
                    iB_buff <= iB_buff;
                end
            end else begin
                iB_buff <= iB_buff;
            end
        end
    end

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrngTop (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iA_inv), 
        .iClr(iClr),
        .sobolseq(sobolseqIn)
    );

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrngBot (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iA), 
        .iClr(iClr),
        .sobolseq(sobolseq)
    );

    sobolrng #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolRandom (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iClr(iClr),
        .sobolseq(sobolseqRan)
    );
    
    assign andTop = iA_inv & ~(iB_buff > sobolseqIn);
    assign andBot = iA & (iB_buff > sobolseq);

    always@(*) begin
        oMult <= andTop | andBot;
        oB <= (iB_buff > sobolseqRan); 
    end

endmodule

`endif


