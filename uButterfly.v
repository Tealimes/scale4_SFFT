//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`ifndef uButterfly
`define uButterfly

`include "uMUL_bi.v"
`include "uSADD.v"
`include "uSSUB.v"

module uButterfly #(
    parameter BITWIDTH = 8,
    parameter BINPUT = 2
) (
    input wire iClk, iRstN, iEn, loadW, iClr,
    input wire iReal0, iImg0, iReal1, iImg1,
    input wire [BITWIDTH-1:0] iwReal, iwImg,   
    output wire oBReal, oBImg,
    output wire oReal0, oImg0, oReal1, oImg1
    
);

    wire eq_Real1_x_wReal;
    wire eq_Real1_x_wImg;
    wire eq_Img1_x_wReal;
    wire eq_Img1_x_wImg;
    wire scalerReal0;
    wire scalerImg0;
    wire real_eq;
    wire img_eq;
    reg biZero;

    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin 
            biZero <= 0;
        end else begin
            biZero <= ~biZero;
        end
    end
    
    //these account for the multiplication of input 1 with w
    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    )u_uMUL_bi_Real1_x_wReal (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iReal1),
        .iB(iwReal),
        .loadB(loadW),
        .iClr(iClr),
        .oB(oBReal),
        .oMult(eq_Real1_x_wReal)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_Real1_x_wImg (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iReal1),
        .iB(iwImg),
        .loadB(loadW),
        .iClr(iClr),
        .oB(oBImg),
        .oMult(eq_Real1_x_wImg)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_Img1_x_wReal (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iImg1),
        .iB(iwReal),
        .loadB(loadW),
        .iClr(iClr),
        .oMult(eq_Img1_x_wReal)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_Img1_x_wImg (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iImg1),
        .iB(iwImg),
        .loadB(loadW),
        .iClr(iClr),
        .oMult(eq_Img1_x_wImg)
    );

    //creates parts to be added and subtracted in butterfly

    uSSUB #(
        .BINPUT(BINPUT)
    ) u_uSSUB_realeq (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(eq_Real1_x_wReal),
        .iB(eq_Img1_x_wImg),
        .oC(real_eq)
    );

    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_imgeq (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(eq_Real1_x_wImg),
        .iB(eq_Img1_x_wReal),
        .oC(img_eq) 
    );

    //scales first input to match with the other scaled equations
    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_scalerReal (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iReal0),
        .iB(biZero),
        .oC(scalerReal0)
    );

    uSADD #(
        .BINPUT(BINPUT)
    ) uSADD_scalerImg (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(iImg0),
        .iB(biZero),
        .oC(scalerImg0)
    );

    //used to find final outputs

    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_oReal0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(scalerReal0),
        .iB(real_eq),
        .oC(oReal0) 
    );

    uSADD #(
        .BINPUT(BINPUT)
    ) u_uSADD_oImg0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(scalerImg0),
        .iB(img_eq),
        .oC(oImg0) 
    );

    uSSUB #(
        .BINPUT(BINPUT)
    ) u_uSSUB_oReal1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(scalerReal0),
        .iB(real_eq),
        .oC(oReal1) 
    );

    uSSUB #(
        .BINPUT(BINPUT)
    ) u_uSSUB_oImg1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iA(scalerImg0),
        .iB(img_eq),
        .oC(oImg1) 
    );
    
endmodule

`endif