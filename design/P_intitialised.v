// <>
// -----------------------------------------------------------------------------------------------------
// ----------------- Program Counter -------------------------------------------------------------------
module Program_Counter (clk, reset, PC_in, PC_out);
    
input clk, reset;
input      [31:0] PC_in;
output reg [31:0] PC_out;

always @(posedge clk or posedge reset) begin
    if (reset) 
        PC_out <= 32'b00;
    else
        PC_out <= PC_in; 
end

endmodule
// ----------------------------------------------------------------------------------------------------

// ----------------- PC + 4 ---------------------------------------------------------------------------
module PCplus4 (fromPC, PC_next);

input  [31:0] fromPC;
output [31:0] PC_next;

assign PC_next = 4 + fromPC;
    
endmodule
// ----------------------------------------------------------------------------------------------------

// ---------------- Instruction Memory (init) ---------------------------------------------------------
module Instruction_Memory (clk, reset, read_address, instruction_out);

input     clk, reset;
input     [31:0] read_address;
output [31:0] instruction_out;

integer k;
reg [31:0] I_mem[63:0];
assign instruction_out = I_mem[read_address];

always@(posedge clk or posedge reset) begin
    if (reset) begin
        for(k=0;k<64;k=k+1) begin
            I_mem[k] <= 32'b00;
        end
    end
    else
//init

    //R-type
        I_mem[0] = 32'b00000000000000000000000000000000 ; // no operation
        I_mem[4] = 32'b0000000_11001_10000_000_01101_0110011 ; // add x13, x16, x25
        I_mem[8] = 32'b0100000_00011_01000_000_00101_0110011 ; // sub x13, x16, x25
        I_mem[12] = 32'b0000000_00011_00010_111_00001_0110011 ; // and x1, x2, x3
        I_mem[16] = 32'b0000000_00101_00011_110_00100_0110011 ; // or x4, x3, x5

    //I-type
        I_mem[20] = 32'b000000000011_10101_000_10110_0010011 ; // addi x22, x21, 3
        I_mem[24] = 32'b010000000001_01000_110_01001_0010011 ; // ori x9, x8, 1

    //L-type
        I_mem[28] = 32'b000000001111_00101_010_01000_0000011 ; // lw x8, 15(x5)
        I_mem[32] = 32'b010000000011_00011_010_01001_0000011 ; // lw x9, 3(x3)

    //S-type
        I_mem[36] = 32'b0000000_01111_00101_010_01100_0100011 ; // sw x15, 12(x5)
        I_mem[40] = 32'b0100000_01110_00110_010_01010_0100011 ; // sw x14, 10(x6)

    //SB-type
        I_mem[44] = 32'h00948663 ; // beq x9, x9, 12

end

endmodule
// ----------------------------------------------------------------------------------------------------

// --------------- Register File ----------------------------------------------------------------------
module Register_File(clk, reset, RegWrite, Rs1, Rs2, Rd, Write_data, Read_data1, Read_data2);

input  clk, reset, RegWrite;
input  [4:0] Rs1,Rs2,Rd;
input  [31:0] Write_data;
output [31:0] Read_data1, Read_data2;

integer k;
reg [31:0] Registers[31:0];

//init
initial begin
Registers[0] = 0;
Registers[1] = 4;
Registers[2] = 2;
Registers[3] = 24;
Registers[4] = 4;
Registers[5] = 1;
Registers[6] = 44;
Registers[7] = 4;
Registers[8] = 2;
Registers[9] = 1;
Registers[10] = 23;
Registers[11] = 4;
Registers[12] = 90;
Registers[13] = 10;
Registers[14] = 20;
Registers[15] = 30;
Registers[16] = 40;
Registers[17] = 50;
Registers[18] = 60;
Registers[19] = 70;
Registers[20] = 80;
Registers[21] = 80;
Registers[22] = 90;
Registers[23] = 70;
Registers[24] = 60;
Registers[25] = 65;
Registers[26] = 4;
Registers[27] = 32;
Registers[28] = 12;
Registers[29] = 34;
Registers[30] = 5;
Registers[31] = 10;
end

always@(posedge clk or posedge reset) begin
    if (reset) begin
        for(k=0;k<32;k=k+1) begin
            Registers[k] <= 32'b00;
        end
    end
    else if(RegWrite) begin
        Registers[Rd] <= Write_data;
    end
end

assign Read_data1 = Registers[Rs1];
assign Read_data2 = Registers[Rs2];

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ Immediate Generator -------------------------------------------------------------------
module Imm_Gen(Opcode, instruction, ImmExt);

input [6:0] Opcode;
input [31:0] instruction;
output reg [31:0] ImmExt;

always @(*) begin
    case (Opcode)
        7'b0000011: // I-type (e.g., Load)
            ImmExt = {{20{instruction[31]}}, instruction[31:20]}; 
        
        7'b0100011: // S-type (e.g., Store)
            ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; 
        
        7'b1100011: // SB-type (e.g., Branch)
            ImmExt = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        
        7'b0010011: // I-type (e.g., Immediate ALU operations)
            ImmExt = {{20{instruction[31]}}, instruction[31:20]};
    endcase
end

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ Control Unit --------------------------------------------------------------------------
module Control_Unit(instruction, branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

input [6:0] instruction;
output reg branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
output reg [1:0] ALUOp;

always@(*) begin
    case(instruction)
        7'b0110011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} <= 8'b001000_10;
        7'b0000011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} <= 8'b111100_00;
        7'b0100011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} <= 8'b100010_00;
        7'b1100011: {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, branch, ALUOp} <= 8'b000001_01;
    endcase
end

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ ALU  ----------------------------------------------------------------------------------
module ALU(A, B, Control_in, ALU_Result, zero);

input [31:0] A,B;
input [3:0] Control_in;
output reg zero;
output reg [31:0] ALU_Result;

always@(Control_in or A or B) begin
    case(Control_in)
        4'b0000: begin
            zero <= 0;
            ALU_Result <= A & B;
        end
        4'b0001: begin
            zero <= 0;
            ALU_Result <= A | B;
        end 
        4'b0010: begin
            zero <= 0;
            ALU_Result <= A + B;
        end 
        4'b0110: begin
            if(A==B) zero <= 1;
            else zero <= 0;
            ALU_Result <= A-B;   
        end
    endcase
end

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ ALU Control  --------------------------------------------------------------------------
module ALU_Control(fun7, fun3, ALUOp, Control_out);

input fun7;
input [2:0] fun3;
input [1:0] ALUOp;
output reg [3:0] Control_out;

always@(*)begin
    case({ALUOp, fun7, fun3})
        6'b00_0_000 : Control_out <= 4'b0010;
        6'b01_0_000 : Control_out <= 4'b0110;
        6'b10_0_000 : Control_out <= 4'b0010;
        6'b10_1_000 : Control_out <= 4'b0110;
        6'b10_0_111 : Control_out <= 4'b0000;
        6'b10_0_110 : Control_out <= 4'b0001; 
    endcase
end

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ Data Memory  --------------------------------------------------------------------------
module Data_Memory(clk, reset, read_address, Write_data, MemWrite, MemRead, MemData_out);

input clk, reset, MemWrite, MemRead;
input [31:0] read_address, Write_data;
output [31:0] MemData_out;

integer k;
reg [31:0] D_Memory [63:0];

always@(posedge clk or posedge reset) begin
    if (reset) begin
        for(k=0;k<64;k=k+1) begin
            D_Memory[k] <= 32'b00;
        end
    end    
    else if(MemWrite) begin
        D_Memory[read_address] <= Write_data;
    end
end

assign MemData_out = (MemRead) ? D_Memory[read_address] : 32'b00;

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ MUX -----------------------------------------------------------------------------------
module Mux(sel, A, B, Mux_out);

input sel;
input [31:0] A,B;
output [31:0] Mux_out;

assign Mux_out = (sel == 1'b0) ? A : B;

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ AND Gate ------------------------------------------------------------------------------
module AND_gate(branch, zero, and_out);

input branch,zero;
output and_out;

assign and_out = (branch & zero); 

endmodule
// ----------------------------------------------------------------------------------------------------

// ------------ Adder ---------------------------------------------------------------------------------
module Adder(in_1, in_2, adder_out);

input [31:0] in_1,in_2;
output [31:0] adder_out;

assign adder_out = (in_1 + in_2);

endmodule
// ----------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------



// ------------ TOP MODULE ----------------------------------------------------------------------------
module top(clk, reset);

input clk,reset;

wire [31:0] PC_top, instruction_top, Rd1_top, Rd2_top, ImmExt_top, mux1_top, adder_top, nextPC_top, mux3_top, ALUres_top, MemData_top, mux2_top;
wire RegWrite_top, ALUSrc_top, branch_top, zero_top, and_top, MemWrite_top, MemRead_top, MemtoReg_top;
wire [1:0] ALUOp_top;
wire [3:0] ctrl_top;

Program_Counter PC( .clk(clk), .reset(reset), .PC_in(mux3_top), .PC_out(PC_top));
PCplus4 PC4( .fromPC(PC_top), .PC_next(nextPC_top));
Instruction_Memory InstMem( .clk(clk), .reset(reset), .read_address(PC_top), .instruction_out(instruction_top));
Register_File RegFile( .clk(clk), .reset(reset), .RegWrite(RegWrite_top), .Rs1(instruction_top[19:15]), .Rs2(instruction_top[24:20]), .Rd(instruction_top[11:7]), .Write_data(mux2_top), .Read_data1(Rd1_top), .Read_data2(Rd2_top));
Imm_Gen ImmGen( .Opcode(instruction_top[6:0]), .instruction(instruction_top), .ImmExt(ImmExt_top));
Control_Unit CtrlUnit( .instruction(instruction_top[6:0]), .branch(branch_top), .MemRead(MemRead_top), .MemtoReg(MemtoReg_top), .ALUOp(ALUOp_top), .MemWrite(MemWrite_top), .ALUSrc(ALUSrc_top), .RegWrite(RegWrite_top));
ALU myALU( .A(Rd1_top), .B(mux1_top), .Control_in(ctrl_top), .ALU_Result(ALUres_top), .zero(zero_top));
ALU_Control ALUCtrl( .fun7(instruction_top[30]), .fun3(instruction_top[14:12]), .ALUOp(ALUOp_top), .Control_out(ctrl_top));
Data_Memory DataMem( .clk(clk), .reset(reset), .read_address(ALUres_top), .Write_data(Rd2_top), .MemWrite(MemWrite_top), .MemRead(MemRead_top), .MemData_out(MemData_top));
Mux mux1( .sel(ALUSrc_top), .A(Rd2_top), .B(ImmExt_top), .Mux_out(mux1_top));
Mux mux2( .sel(MemtoReg_top), .A(ALUres_top), .B(MemData_top), .Mux_out(mux2_top));
Mux mux3( .sel(and_top), .A(nextPC_top), .B(adder_top), .Mux_out(mux3_top));
AND_gate myAnd( .branch(branch_top), .zero(zero_top), .and_out(and_top));
Adder myAdder( .in_1(PC_top), .in_2(ImmExt_top), .adder_out(adder_top));


endmodule
// ----------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------

// ------------ Testbench -----------------------------------------------------------------------------
module top_tb;

reg clk, reset;

top dut( .clk(clk), .reset(reset));

initial begin
    clk = 0;
    reset = 1;
    #5;
    reset = 0;
    #400;
end

always begin
    #5 clk = ~clk;
end

endmodule