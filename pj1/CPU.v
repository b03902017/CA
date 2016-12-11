module CPU
(
    clk_i,
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire [31:0] inst_addr, inst, pc_i, pc_add4;


wire [2:0] aluop, aluop_ctrl; // control signal
wire regdst, regdst_ctrl, alusrc, alusrc_ctrl, regwrite, regwrite_ctrl, branch_ctrl, jump_ctrl;//control signal
wire [2:0] aluctrl; // ALU control
wire [4:0] dst_o; // reg destination
wire [31:0] reg_rsdata, reg_rtdata; // registers
wire [31:0] extended; // sign extended
wire [31:0] shifted_32bit; //for beq immediate shift2
wire [27:0] shifted_28bit; //for j immediate shift2
wire [31:0] ALUsrc; // ALU source
wire [31:0] ALUout; //ALU
wire ALUzero; // ALU
wire memread, memread_ctrl, memwrite, memwrite_ctrl, mem2reg, mem2reg_ctrl; // data memory
wire [31:0] dmdata; // data from data memory

wire equal_ornot; //for beq equal
wire [31:0] IFIDpc, IFIDinst; 
wire branch_select; //for mux1 to select branch pc or pc+4
wire [31:0] branch_pc; //after adding pc+4 and shifted_32bit
wire [31:0] j_pc; //after caculating j's pc
wire [31:0] mux1_o; //after selecting using pc+4 or branch_pc
wire flush_bit; //flush or not
wire [31:0] rsdata, rtdata; // send to IDEX


wire IDEXregdst, IDEXalusrc, IDEXregwrite;
wire IDEXmemread, IDEXmemwrite, IDEXmem2reg;
wire [2:0] IDEXaluop;
wire [31:0] IDEXrsdata, IDEXrtdata, IDEXimmediate;
wire [4:0] IDEXrsaddr, IDEXrtaddr, IDEXrdaddr;
wire [5:0] IDEXfunc;

wire [1:0] forwardA, forwardB;
wire [31:0] ALUrsdata, ALUrtdata;

wire EXMEMregwrite;
wire [31:0] EXMEMaluout;
wire [4:0]  EXMEMregdst;
wire EXMEMmemread, EXMEMmemwrite, EXMEMmem2reg;
wire [31:0] EXMEMalurtdata;

wire MEMWBregwrite;
wire MEMWBmem2reg;
wire [31:0] MEMWBaluout;
wire [4:0]  MEMWBregdst;
wire [31:0] MEMWBdmdata;

wire [31:0] data2reg;
wire IDforwardA, IDforwardB;

// stall control
wire bubble_ctrl, IFIDwrite, pcwrite;

// ----IF stage---- //
Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (pc_add4)
);

OR OR(
    .data1_i	(jump_ctrl),
    .data2_i	(branch_select),
    .data_o	(flush_bit)
);

AND_gate AND_for_beq(
    .data1_i	(branch_ctrl),
    .data2_i	(equal_ornot),
    .data_o	(branch_select)
);

MUX32 MUX1_for_beq(
    .data1_i	(pc_add4),
    .data2_i	(branch_pc),
    .select_i	(branch_select),
    .data_o	(mux1_o)
);

MUX32 MUX2_for_jump(
    .data1_i	(mux1_o),
    .data2_i	(j_pc),
    .select_i	(jump_ctrl),
    .data_o	(pc_i)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (pc_i),
    .pcwrite    (pcwrite),
    .pc_o       (inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr),
    .instr_o    (inst)
);


IFIDRegister IFIDRegister(
    .clk_i  (clk_i),
    .pc_i   (pc_add4),
    .inst_i (inst),
    .IFIDwrite  (IFIDwrite),
    .IFIDflush	(flush_bit),
    .pc_o   (IFIDpc),
    .inst_o (IFIDinst)
);

// ----ID stage---- //
Control Control(
    .Op_i       (IFIDinst[31:26]),
    .RegDst_o   (regdst),
    .ALUOp_o    (aluop),
    .ALUSrc_o   (alusrc),
    .RegWrite_o (regwrite),
    .Memread_o  (memread),
    .Memwrite_o (memwrite),
    .Mem2reg_o  (mem2reg),
    .Branch_o	(branch_ctrl),
    .Jump_o	(jump_ctrl)
);

Combine combine_forJ(
    .data1_i	(shifted_28bit),
    .data2_i	(mux1_o[31:28]),
    .data_o	(j_pc)
);

Equal Equal_for_beq(
    .data1_i	(rsdata),
    .data2_i	(rtdata),
    .data_o	(equal_ornot)
);

Shift_left2_26bit Shift_left2_forJ(
    .data_i	(IFIDinst[25:0]),
    .data_o	(shifted_28bit)
);

MUX_stall MUX_stall(
    .data1_i  ({regdst,aluop,alusrc,
                regwrite,memread,memwrite,mem2reg}),
    .select_i (bubble_ctrl),
    .data_o   ({regdst_ctrl,aluop_ctrl,alusrc_ctrl,
        regwrite_ctrl,memread_ctrl,memwrite_ctrl,mem2reg_ctrl})
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (IFIDinst[25:21]),
    .RTaddr_i   (IFIDinst[20:16]),
    .RDaddr_i   (MEMWBregdst),
    .RDdata_i   (data2reg),
    .RegWrite_i (MEMWBregwrite),
    .RSdata_o   (reg_rsdata),
    .RTdata_o   (reg_rtdata)
);

Shift_left2_32bit Shift_left2_forBEQ(
    .data_i	(extended),
    .data_o	(shifted_32bit)
);

Adder Add_forBEQ(
    .data1_in	(shifted_32bit),
    .data2_in	(IFIDpc),
    .data_o	(branch_pc)
);

Sign_Extend Sign_Extend(
    .data_i     (IFIDinst[15:0]),
    .data_o     (extended)
);

HazardDetection HazardDetection(
    .IDEXmemread    (IDEXmemread),
    .IDEXrtaddr     (IDEXrtaddr),
    .IFIDrsaddr     (IFIDinst[25:21]),
    .IFIDrtaddr     (IFIDinst[20:16]),
    .bubble_ctrl    (bubble_ctrl),
    .IFIDwrite      (IFIDwrite),
    .pcwrite        (pcwrite)
);

MUX32 IDRsForward(
    .data1_i    (reg_rsdata),
    .data2_i    (data2reg),
    .select_i   (IDforwardA),
    .data_o     (rsdata)
);

MUX32 IDRtForward(
    .data1_i    (reg_rtdata),
    .data2_i    (data2reg),
    .select_i   (IDforwardB),
    .data_o     (rtdata)
);

IDEXRegister IDEXRegister(
    .clk_i          (clk_i),
    .regdst_ctrl    (regdst_ctrl),
    .aluop_ctrl     (aluop_ctrl),
    .alusrc_ctrl    (alusrc_ctrl),
    .regwrite_ctrl  (regwrite_ctrl),
    .memread_ctrl   (memread_ctrl),
    .memwrite_ctrl  (memwrite_ctrl),
    .mem2reg_ctrl   (mem2reg_ctrl),
    .rsdata_i       (rsdata),
    .rtdata_i       (rtdata),
    .immediate_i    (extended),
    .rsaddr_i       (IFIDinst[25:21]),
    .rtaddr_i       (IFIDinst[20:16]),
    .rdaddr_i       (IFIDinst[15:11]),
    .func_i         (IFIDinst[5:0]),
    .regdst_o       (IDEXregdst),
    .aluop_o        (IDEXaluop),
    .alusrc_o       (IDEXalusrc),
    .regwrite_o     (IDEXregwrite),
    .memread_o      (IDEXmemread),
    .memwrite_o     (IDEXmemwrite),
    .mem2reg_o      (IDEXmem2reg),
    .rsdata_o       (IDEXrsdata),
    .rtdata_o       (IDEXrtdata),
    .immediate_o    (IDEXimmediate),
    .rsaddr_o       (IDEXrsaddr),
    .rtaddr_o       (IDEXrtaddr),
    .rdaddr_o       (IDEXrdaddr),
    .func_o         (IDEXfunc)
);

// ---- EX stage ---- //

MUX5 MUX_RegDst(
    .data1_i    (IDEXrtaddr),
    .data2_i    (IDEXrdaddr),
    .select_i   (IDEXregdst),
    .data_o     (dst_o)
);


MUX32_3way RsForward(
    .data1_i    (IDEXrsdata),
    .data2_i    (data2reg),
    .data3_i    (EXMEMaluout),
    .select_i   (forwardA),
    .data_o     (ALUrsdata)
);

MUX32_3way RtForward(
    .data1_i    (IDEXrtdata),
    .data2_i    (data2reg),
    .data3_i    (EXMEMaluout),
    .select_i   (forwardB),
    .data_o     (ALUrtdata)
);


MUX32 MUX_ALUSrc(
    .data1_i    (ALUrtdata),
    .data2_i    (IDEXimmediate),
    .select_i   (IDEXalusrc),
    .data_o     (ALUsrc)
);

ALU_Control ALU_Control(
    .funct_i    (IDEXfunc),
    .ALUOp_i    (IDEXaluop),
    .ALUCtrl_o  (aluctrl)
);


ALU ALU(
    .data1_i    (ALUrsdata),
    .data2_i    (ALUsrc),
    .ALUCtrl_i  (aluctrl),
    .data_o     (ALUout),
    .Zero_o     (ALUzero)
);


EXMEMregister EXMEMregister(
    .clk_i      (clk_i),
    .regwrite_i (IDEXregwrite),
    .ALUout_i   (ALUout),
    .regdst_i   (dst_o),
    .ALUrtdata_i(ALUrtdata),
    .memread_i  (IDEXmemread),
    .memwrite_i (IDEXmemwrite),
    .mem2reg_i  (IDEXmem2reg),
    .regwrite_o (EXMEMregwrite),
    .ALUout_o   (EXMEMaluout),
    .regdst_o   (EXMEMregdst),
    .ALUrtdata_o(EXMEMalurtdata),
    .memread_o  (EXMEMmemread),
    .memwrite_o (EXMEMmemwrite),
    .mem2reg_o  (EXMEMmem2reg)
);

ForwardingUnit ForwardingUnit(
    .IDEXrsaddr     (IDEXrsaddr),
    .IDEXrtaddr     (IDEXrtaddr),
    .EXMEMregwrite  (EXMEMregwrite),
    .EXMEMregdst    (EXMEMregdst),
    .MEMWBregwrite  (MEMWBregwrite),
    .MEMWBregdst    (MEMWBregdst),
    .forwardA       (forwardA),
    .forwardB       (forwardB)
);
// ---- MEM stage ---- //

Data_Memory Data_Memory(
    .addr_i     (EXMEMaluout),
    .memread    (EXMEMmemread),
    .memwrite   (EXMEMmemwrite),
    .data_i     (EXMEMalurtdata),
    .data_o     (dmdata)
);

MEMWBregister MEMWBregister(
    .clk_i      (clk_i),
    .regwrite_i (EXMEMregwrite),
    .ALUout_i   (EXMEMaluout),
    .regdst_i   (EXMEMregdst),
    .mem2reg_i  (EXMEMmem2reg),
    .dmdata_i   (dmdata),
    .regwrite_o (MEMWBregwrite),
    .ALUout_o   (MEMWBaluout),
    .regdst_o   (MEMWBregdst),
    .mem2reg_o  (MEMWBmem2reg),
    .dmdata_o   (MEMWBdmdata)
);

// ---- WB stage ---- //

MUX32 Mux_memreg(
    .data1_i (MEMWBaluout),
    .data2_i (MEMWBdmdata),
    .select_i (MEMWBmem2reg),
    .data_o   (data2reg)
);

IDForwarding IDForwarding(
	.IFIDrsaddr    (IFIDinst[25:21]),
	.IFIDrtaddr    (IFIDinst[20:16]),
	.MEMWBregwrite (MEMWBregwrite),
	.MEMWBregdst   (MEMWBregdst),
	.IDforwardA    (IDforwardA),
	.IDforwardB    (IDforwardB)
);

endmodule
