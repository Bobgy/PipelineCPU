`include "header.v"

module top(
    input CCLK,
    input [3:0] BTN,
    input [3:0] SW,
    output LCDRS, LCDRW, LCDE,
    output [3:0] LCDDAT,
    output [7:0] LED
);

    /*  ------- interface ------- */

    wire [3:0] lcdd;
    wire rslcd, rwlcd, elcd;
    wire debpb1, clk_lcd, clk_lcd_ref;

    reg [255:0] strdata = "P:3456I:12345678C:3456R:12345678";
    reg [3:0] temp=0;

    assign LCDDAT=lcdd,
           LCDRS=rslcd,
           LCDRW=rwlcd,
           LCDE=elcd;

    display M0 (CCLK, clk_lcd_ref, strdata, rslcd, rwlcd, elcd, lcdd);

    clock clock0 (CCLK, 25000, clk_lcd);
    clock clock1 (CCLK, 5000000, clk_lcd_ref);
    pbdebounce_lcd pbd1 (clk_lcd, BTN[1], debpb1);     //EAST
    pbdebounce_lcd pbd2 (clk_lcd, BTN[2], clk);        //SOUTH
    pbdebounce_lcd pbd3 (clk_lcd, BTN[3], rst);        //WEST

    /* --------- stages -------- */

    //if_stage x_if_stage(.clk(clk), .rst(rst), pc, mem_pc, mem_branch,
    //    IF_ins_type, IF_ins_number,ID_ins_type,ID_ins_number);

    /* --------- if stage ---------- */

    wire [31:0] I;
    wire [8:0] i_pc, branch_dst;

    ProgramCounter #(9) pc0(~clk, rst, i_pc, o_pc);
    // branch and jump
    assign next_pc = o_pc + 1;
    wire branch, invBranch, jump; // assigned in MEM stage
    assign branch_dst = (branch & (MEM_S_is_zero ^ invBranch)) ? MEM_NPC : next_pc;
    assign i_pc = jump ? MEM_I[25:0] : branch_dst;

    InstructionMemory instr_mem(.addra(o_pc), .clka(clk), .douta(I));

    // regs
    reg [31:0] ID_PC, ID_I;
    reg [31:0] ID_NPC, EX_NPC, MEM_NPC;

    always @(posedge clk) begin
        ID_PC  <= o_pc;
        ID_I   <= I;
        ID_NPC <= next_pc;
    end


    /* ------ id stage ------ */

    // related to cpu_controller
    wire [11:0] sig;

    CpuController cpu_ctrl(.op(ID_PC[31:26]), .sig(sig));
    wire `ctrl_sig;
    assign {`ctrl_sig} = sig;

    // related to regfile
    wire [31:0] A, B, C, immed, data_write;
    wire [4:0] reg_write, reg_disp;

    assign disp_addr = {debpb1, SW}; // for debug
	
    reg EX_WriteReg, MEM_WriteReg, WB_WriteReg;
    RegFile reg_file(.clk(~clk), .rst(rst), .regA(ID_I[25:21]), .regB(ID_I[20:16]),
                .regW(WB_RegDst), .Wdat(data_write), .Adat(A), .Bdat(B),
                .RegWrite(WB_WriteReg), .regC(reg_disp), .Cdat(C));

    // extension
    Extension ext(.zero(ZeroExtend), .i_16(ID_I[15:0]), .o_32(immed));

    // regs
    reg [31:0] EX_I, EX_A, EX_B, EX_immed;

    reg EX_ALUSrcB, EX_MemWrite, EX_RegDst;
	 reg EX_MemToReg, MEM_MemToReg, WB_MemToReg;
	 
    reg [2:0] EX_branch_sig, MEM_branch_sig;

    reg EX_Branch, MEM_Branch;
    reg EX_InvBranch, MEM_InvBranch;
    reg EX_Jump, MEM_Jump;
    reg [2:0] EX_ALUop;

    always @(posedge clk) begin
        EX_I <= ID_I;
        EX_A <= A;
        EX_B <= B;
        EX_immed <= immed;
        EX_NPC <= ID_NPC;

        // signals
        EX_ALUSrcB <= ALUSrcB;
        EX_ALUop <= {ALUop2, ALUop1, ALUop0};
        EX_MemWrite <= MemWrite;
        EX_WriteReg <= WriteReg;
        EX_MemToReg <= MemToReg;
        EX_RegDst <= RegDst;
        EX_branch_sig <= {Branch, InvBranch, Jump};
    end

    /* ------- ex stage ------- */

    // ALU
    wire [5:0] func = EX_I[5:0];
    wire [2:0] aluc_sig;
    ALUCtrl aluc(.op(EX_ALUop), .sw(func), .aluc(aluc_sig));

    wire [31:0] result;
    wire is_zero;

    wire [31:0] alu_src_B = EX_ALUSrcB ? EX_immed : EX_B;
    wire [4:0]  shamt = EX_I[10:6];

    ALU alu0(EX_A, alu_src_B, aluc_sig, shamt, result, is_zero);

    // regs
    reg [4:0] MEM_reg_dst, WB_reg_dst;
    reg [31:0] MEM_I, MEM_S, MEM_B;
    reg MEM_MemWrite, MEM_S_is_zero;

    always @(posedge clk) begin
        MEM_I <= EX_I;
        MEM_B <= EX_B;
        MEM_S <= result;
        MEM_reg_dst <= EX_RegDst ? WB_I[15:11] : WB_I[20:16];
        MEM_NPC <= EX_NPC + EX_immed;
        MEM_S_is_zero <= is_zero;

        //signals
        MEM_MemWrite <= EX_MemWrite;
        MEM_WriteReg <= WriteReg;
        MEM_MemToReg <= MemToReg;
        MEM_branch_sig <= EX_branch_sig;
    end

    /* ------ mem stage ------- */

    // branch
    assign {branch, invBranch, jump} = MEM_branch_sig;

    // Data Memory
    wire [31:0] mem_data;
    DataMem data1(
        .addra(MEM_S), // Bus [8 : 0]
        .dina(MEM_B), // Bus [31 : 0]
        .clka(clk),
        .wea(MEM_MemWrite),
        .douta(mem_data)); // Bus [31 : 0]

    // regs
    reg [31:0] WB_I, WB_mem_data, WB_S;

    always @(posedge clk) begin
        WB_I <= MEM_I;
        WB_mem_data <= mem_data;
        WB_S <= MEM_S;
        WB_reg_dst <= MEM_reg_dst;

        //signals
        WB_WriteReg <= WriteReg;
        WB_MemToReg <= MemToReg;
    end

    /* ----- wb stage ----- */

    assign data_write = WB_MemToReg ? WB_mem_data : WB_S;

    /* ----- display ----- */

    reg [31:0] disp_code;
    reg [15:0] cnt;
    always @(posedge clk or posedge rst)
        cnt <= rst ? 0 : cnt+1;
    always @* begin
        disp_code <= C;
    end

    assign LED[0] = SW[0];
    assign LED[1] = SW[1];
    assign LED[2] = SW[2];
    assign LED[3] = SW[3];
    assign LED[4] = clk;
    assign LED[5] = rst;
    assign LED[6] = cnt[0];
    assign LED[7] = cnt[1];

    wire [63:0] reg_asc, cnt_asc, pc_asc, I_asc;

    bin2asc_32  b2a0(C, reg_asc),
                b2a1(cnt, cnt_asc),
                b2a2(o_pc, pc_asc),
                b2a3(I, I_asc);

    always @(posedge clk_lcd) begin
        strdata[63:0] <= reg_asc;
        strdata[111:80] <= cnt_asc;
        strdata[239:208] <= pc_asc;
        strdata[191:128] <= I_asc;
    end

endmodule
