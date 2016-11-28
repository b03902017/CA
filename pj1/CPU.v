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

wire [31:0] inst_addr, inst, pc_i;

wire [2:0] aluop_ctrl; // control signal
wire regdst_ctrl, alusrc_ctrl, regwrite_ctrl;//control signal
wire [2:0] aluctrl; // ALU control
wire [4:0] dst_o; // reg destination
wire [31:0] rsdata, rtdata; // registers
wire [31:0] extended; // sign extended
wire [31:0] ALUsrc; // ALU source
wire [31:0] ALUout; //ALU
wire ALUzero; // ALU

wire [31:0] IFIDpc, IFIDinst; 

wire IDEXregdst, IDEXalusrc, IDEXregwrite;
wire [2:0] IDEXaluop;
wire [31:0] IDEXrsdata, IDEXrtdata, IDEXimmediate;
wire [4:0] IDEXrsaddr, IDEXrtaddr, IDEXrdaddr;
wire [5:0] IDEXfunc;

wire [1:0] forwardA, forwardB;
wire [31:0] ALUrsdata, ALUrtdata;

wire EXMEMregwrite;
wire [31:0] EXMEMaluout;
wire [4:0]  EXMEMregdst;

wire MEMWBregwrite;
wire [31:0] MEMWBaluout;
wire [4:0]  MEMWBregdst;


// ----IF stage---- //
Adder Add_PC(
    .data1_in   (inst_addr),
    .data2_in   (32'd4),
    .data_o     (pc_i)
);


PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (pc_i),
    .pc_o       (inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr),
    .instr_o    (inst)
);


IFIDRegister IFIDRegister(
    .clk_i  (clk_i),
    .pc_i   (inst_addr),
    .inst_i (inst),
    .pc_o   (IFIDpc),
    .inst_o (IFIDinst)
);

// ----ID stage---- //
Control Control(
    .Op_i       (IFIDinst[31:26]),
    .RegDst_o   (regdst_ctrl),
    .ALUOp_o    (aluop_ctrl),
    .ALUSrc_o   (alusrc_ctrl),
    .RegWrite_o (regwrite_ctrl)
);



Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (IFIDinst[25:21]),
    .RTaddr_i   (IFIDinst[20:16]),
    .RDaddr_i   (MEMWBregdst), 
    .RDdata_i   (MEMWBaluout), 
    .RegWrite_i (MEMWBregwrite), 
    .RSdata_o   (rsdata), 
    .RTdata_o   (rtdata) 
);


Sign_Extend Sign_Extend(
    .data_i     (IFIDinst[15:0]),
    .data_o     (extended)
);


IDEXRegister IDEXRegister(
    .clk_i          (clk_i),
    .regdst_ctrl    (regdst_ctrl),
    .aluop_ctrl     (aluop_ctrl),
    .alusrc_ctrl    (alusrc_ctrl),
    .regwrite_ctrl  (regwrite_ctrl),
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
    .data2_i    (MEMWBaluout),
    .data3_i    (EXMEMaluout),
    .select_i   (forwardA),
    .data_o     (ALUrsdata)
);

MUX32_3way RtForward(
    .data1_i    (IDEXrtdata),
    .data2_i    (MEMWBaluout),
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
    .regwrite_o (EXMEMregwrite),
    .ALUout_o   (EXMEMaluout),
    .regdst_o   (EXMEMregdst)
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

MEMWBregister MEMWBregister(
    .clk_i      (clk_i),
    .regwrite_i (EXMEMregwrite),
    .ALUout_i   (EXMEMaluout),
    .regdst_i   (EXMEMregdst),
    .regwrite_o (MEMWBregwrite),
    .ALUout_o   (MEMWBaluout),
    .regdst_o   (MEMWBregdst)
);

// ---- WB stage ---- //



endmodule

