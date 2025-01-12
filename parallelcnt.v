//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com
`ifndef parallelcnt
`define parallelcnt

module parallelcnt (
    input wire iA,
    input wire iB,
    output wire [1:0] PCout
);

    assign PCout = iA + iB;

endmodule

`endif
