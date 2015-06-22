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

    reg [63:0] str0 = "12345678", str1 = "87654321";
    reg [127:0] str2 = "FD06|E03|M07|W0A";
    reg [3:0] temp=0;

    assign LCDDAT=lcdd,
           LCDRS=rslcd,
           LCDRW=rwlcd,
           LCDE=elcd;

    display M0(CCLK, clk_lcd_ref, {str0, str1, str2}, rslcd, rwlcd, elcd, lcdd);

    clock clock0(CCLK, 25000, clk_lcd);
    clock clock1(CCLK, 5000000, clk_lcd_ref);

    pbdebounce_lcd pbd1 (clk_lcd, BTN[1], debpb1);     //EAST
    pbdebounce_lcd pbd2 (clk_lcd, BTN[2], clk);        //SOUTH
    pbdebounce_lcd pbd3 (clk_lcd, BTN[3], rst);        //WEST

    //for simulation
    //assign clk = BTN[2], rst = BTN[3];

    /* --------- stages -------- */

    //if_stage x_if_stage(.clk(clk), .rst(rst), pc, mem_pc, mem_branch,
    //    IF_ins_type, IF_ins_number,ID_ins_type,ID_ins_number);

    /* --------- if stage ---------- */

    wire [31:0] I;
    wire [8:0] i_pc, branch_dst, o_pc, next_pc;

    ProgramCounter #(9) pc0(clk, rst, i_pc, o_pc);
    // branch and jump
    assign next_pc = o_pc + 1;
    wire branch, invBranch, jump; // assigned in MEM stage
    assign branch_dst = (branch & (MEM_S_is_zero ^ invBranch)) ? MEM_NPC : next_pc;
    assign i_pc = jump ? MEM_I[25:0] : branch_dst;

    InstrMem instr_mem(.addra(i_pc), .clka(clk), .douta(I), .wea(1'b0), .dina(32'b0));

    // regs
    reg [31:0] ID_I=0;
    reg [31:0] ID_NPC, EX_NPC, MEM_NPC;

    always @(posedge clk) begin
        ID_I   <= rst ? 0 : I;
        ID_NPC <= next_pc;
    end


    /* ------ id stage ------ */

    // related to cpu_controller
    wire [11:0] sig;

    CpuController cpu_ctrl(.op(ID_I[31:26]), .sig(sig));
    wire `ctrl_sig;
    assign {`ctrl_sig} = sig;

    // related to regfile
    wire [31:0] A, B, C, immed, data_write;
    wire [4:0] reg_disp;

    assign reg_disp = {debpb1, SW}; // for debug
    reg [4:0] WB_reg_dst; //assigned in MEM stage
    reg EX_WriteReg, MEM_WriteReg, WB_WriteReg;
    RegFile reg_file(.clk(~clk), .rst(rst), .regA(ID_I[25:21]),
        .regB(ID_I[20:16]), .regW(WB_reg_dst), .Wdat(data_write),
        .Adat(A), .Bdat(B), .RegWrite(WB_WriteReg),
        .regC(reg_disp), .Cdat(C));

    // extension
    Extension ext(.zero(ZeroExt), .i_16(ID_I[15:0]), .o_32(immed));

    // regs
    reg [31:0] EX_I=0, EX_A, EX_B, EX_immed;

    reg EX_ALUSrcB, EX_MemWrite, EX_RegDst;
    reg EX_MemToReg, MEM_MemToReg, WB_MemToReg;

    reg [2:0] EX_branch_sig, MEM_branch_sig;
    reg [2:0] EX_ALUop;

    always @(posedge clk) begin
        EX_I <= rst ? 0 : ID_I;
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
    reg [4:0] MEM_reg_dst;
    reg [31:0] MEM_I=0, MEM_S, MEM_B;
    reg MEM_MemWrite, MEM_S_is_zero;

    always @(posedge clk) begin
        MEM_I <= rst ? 0 : EX_I;
        MEM_B <= EX_B;
        MEM_S <= result;
        MEM_reg_dst <= EX_RegDst ? EX_I[15:11] : EX_I[20:16];
        MEM_NPC <= EX_NPC + EX_immed;
        MEM_S_is_zero <= is_zero;

        //signals
        MEM_MemWrite <= EX_MemWrite;
        MEM_WriteReg <= EX_WriteReg;
        MEM_MemToReg <= EX_MemToReg;
        MEM_branch_sig <= EX_branch_sig;
    end

    /* ------ mem stage ------- */

    // branch
    assign {branch, invBranch, jump} = MEM_branch_sig;

    // Data Memory
    wire [31:0] mem_data;
    DataMem data1(
        .addra(MEM_S), // Bus [8 : 0]
        .dina(MEM_B),  // Bus [31 : 0]
        .clka(clk),
        .wea(MEM_MemWrite),
        .douta(mem_data)); // Bus [31 : 0]

    // regs
    reg [31:0] WB_I=0, WB_mem_data, WB_S;

    always @(posedge clk) begin
        WB_I <= rst ? 0 : MEM_I;
        WB_mem_data <= mem_data;
        WB_S <= MEM_S;
        WB_reg_dst <= MEM_reg_dst;

        //signals
        WB_WriteReg <= MEM_WriteReg;
        WB_MemToReg <= MEM_MemToReg;
    end

    /* ----- wb stage ----- */

    assign data_write = WB_MemToReg ? WB_mem_data : WB_S;

    /* ----- display ----- */

    reg [31:0] cnt;
    always @(posedge clk or posedge rst)
        cnt <= rst ? 0 : cnt+32'b1;

    assign LED[0] = SW[0];
    assign LED[1] = SW[1];
    assign LED[2] = SW[2];
    assign LED[3] = SW[3];
    assign LED[4] = clk;
    assign LED[5] = rst;
    assign LED[6] = cnt[0];
    assign LED[7] = cnt[1];

    wire [63:0] reg_asc, I_asc;
    wire [15:0] ID_type_asc, EX_type_asc, MEM_type_asc, WB_type_asc;

    bin2asc_32  b2a0(C, reg_asc),
                b2a1(ID_I, I_asc);

    ParseType prsTp0(ID_I, ID_type_asc),
              prsTp1(EX_I, EX_type_asc),
              prsTp2(MEM_I, MEM_type_asc),
              prsTp3(WB_I, WB_type_asc);

    always @* begin
        str0 <= I_asc;
        str1 <= reg_asc;
        str2[15:0] <= WB_type_asc;
        str2[47:32] <= MEM_type_asc;
        str2[79:64] <= EX_type_asc;
        str2[111:96] <= ID_type_asc;
    end

endmodule
