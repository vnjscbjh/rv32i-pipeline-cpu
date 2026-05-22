`include "ctrl_signal_def.v"


module DM(
    input  [11:2] Addr,         
    input  [31:0] WD,           
    input         clk,          
    input         DMCtrl,      
    input  [31:0] real_B,
    output reg [31:0] RD          
);


reg [31:0] memory[0:1023];
reg [31:0] real_B_MEM;
Flopr U_real_B_EX_MEM (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0), .in_data(real_B), .out_data(real_B_MEM));


always @(posedge clk) begin
    if (DMCtrl) begin
        memory[Addr] <= real_B_MEM;
    end
    RD <= memory[Addr];
end


//assign RD = memory[Addr];

endmodule

