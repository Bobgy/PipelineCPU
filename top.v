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

    // regs in group
    reg [31:0] ID_I=0, EX_I=0, MEM_I=0, WB_I=0;
    reg [31:0] ID_NPC;
    reg [31:0] EX_B, MEM_B;
    reg EX_MemToReg, MEM_MemToReg, WB_MemToReg;
    reg [4:0] EX_reg_dst, MEM_reg_dst, WB_reg_dst;
    reg EX_WriteReg, WB_WriteReg, MEM_WriteReg;
    reg [31:0] MEM_S, WB_S;

    // regs alone
    reg EX_ALUSrcB, EX_MemWrite;
    reg [2:0] EX_ALUop;
    reg [31:0] EX_A, EX_immed;
    reg MEM_MemWrite, MEM_S_is_zero;
    reg [31:0] WB_mem_data;
    reg ID_Bubble, EX_Bubble, MEM_Bubble, WB_Bubble;

    // signals
    wire stall, EX_data_hazard, MEM_data_hazard;

    // related to regfile in ID stage
    wire [31:0] A, B, C, immed, WB_data, MEM_data;
    wire [4:0] reg_disp;

    // related to cpu controller
    wire `ctrl_sig;

    /* --------- if stage ---------- */

    wire [31:0] I;
    wire [8:0] i_pc, branch_dst, o_pc, next_pc;

    ProgramCounter #(9) pc0(
        .clk(clk), .rst(rst),
        .i_pc(i_pc), .o_pc(o_pc)
    );

    wire [31:0] pc_A_WB, pc_A;
    Forward forward_pc_A_WB(
        .data0 (A),
        .data1 (WB_data),
        .write (!WB_Bubble && WB_WriteReg),
        .same_addr (WB_reg_dst == ID_I[`RS]),
        .data (pc_A_WB)
    );
    Forward forward_pc_A_MEM(
        .data0 (pc_A_WB),
        .data1 (MEM_data),
        .write (!MEM_Bubble && MEM_WriteReg),
        .same_addr (MEM_reg_dst == ID_I[`RS]),
        .data (pc_A)
    );

    wire [31:0] pc_B_WB, pc_B;
    Forward forward_pc_B_WB(
        .data0 (B),
        .data1 (WB_data),
        .write (!WB_Bubble && WB_WriteReg),
        .same_addr (WB_reg_dst == ID_I[`RT]),
        .data (pc_B_WB)
    );
    Forward forward_pc_B_MEM(
        .data0 (pc_B_WB),
        .data1 (MEM_data),
        .write (!MEM_Bubble && MEM_WriteReg),
        .same_addr (MEM_reg_dst == ID_I[`RT]),
        .data (pc_B)
    );

    wire BranchTaken = Branch && ((pc_A==pc_B) ^ InvBranch);

    // branch and jump
    assign next_pc = o_pc + 1;
    assign branch_dst = BranchTaken ? ID_NPC+immed : next_pc;
    assign i_pc = stall ? o_pc : (Jump ? ID_I[25:0] : branch_dst);

    InstrMem instr_mem(.addra(o_pc), .clka(~clk), .douta(I));

    always @(posedge clk) begin
        if (rst) begin
            {ID_I, ID_NPC} <= 0;
            ID_Bubble <= 1;
        end else if (stall) begin
            ID_I <= ID_I;
            ID_NPC <= ID_NPC;
            ID_Bubble <= ID_Bubble;
        end else if (BranchTaken||Jump) begin
            {ID_I, ID_NPC} <= 0;
            ID_Bubble <= 1;
        end else begin //clock
            ID_I   <= I;
            ID_NPC <= next_pc;
            ID_Bubble <= 0;
        end
    end

    /* ------ id stage ------ */

    // related to cpu_controller
    wire [11:0] sig;

    CpuController cpu_ctrl(.op(ID_I[31:26]), .sig(sig));
    assign {`ctrl_sig} = sig;

    wire [1:0] readRs, readRt;
    InstrRegRead instrRegRead0(
        .I(ID_I),
        .readRs(readRs),
        .readRt(readRt)
    );

    assign stall = (
        !EX_Bubble && EX_WriteReg
        && (
            (EX_reg_dst==ID_I[`RS] && readRs<=`READ_AT_ID+EX_MemToReg)
         || (EX_reg_dst==ID_I[`RT] && readRt<=`READ_AT_ID+EX_MemToReg)
        )
    ) || (
        !MEM_Bubble && MEM_WriteReg && MEM_MemToReg
        && (
            (MEM_reg_dst==ID_I[`RS] && readRs==`READ_AT_ID)
         || (MEM_reg_dst==ID_I[`RT] && readRt==`READ_AT_ID)
        )
    );

    assign reg_disp = {debpb1, SW}; // for debug
    RegFile reg_file(
        .clk(~clk), .rst(rst),
        .regA(ID_I[`RS]), .regB(ID_I[`RT]), .regW(WB_reg_dst),
        .Wdat(WB_data), .Adat(A), .Bdat(B), .RegWrite(WB_WriteReg),
        .regC(reg_disp), .Cdat(C)
    );

    // extension
    Extension ext(.zero(ZeroExt), .i_16(ID_I[`IMMED]), .o_32(immed));

    always @(posedge clk) begin
        if (rst || stall) begin
            {EX_I, EX_A, EX_B, EX_immed} <= 0;
            {EX_ALUSrcB, EX_ALUop, EX_MemWrite} <= 0;
            {EX_MemToReg, EX_reg_dst} <= 0;
            {EX_WriteReg} <= 0;
            EX_Bubble <= 1;
		  end else begin
            EX_I <= ID_I;
            EX_A <= A;
            EX_B <= B;
            EX_immed <= immed;
            EX_reg_dst <= RegDst ? ID_I[`RD] : ID_I[`RT];
            // signals
            EX_ALUSrcB <= ALUSrcB;
            EX_ALUop <= {ALUop2, ALUop1, ALUop0};
            EX_MemWrite <= MemWrite;
            EX_WriteReg <= WriteReg;
            EX_MemToReg <= MemToReg;
            EX_Bubble <= ID_Bubble;
        end
    end

    /* ------- ex stage ------- */

    // ALU
    wire [5:0] func = EX_I[`FN];
    wire [2:0] aluc_sig;
    ALUCtrl aluc(.op(EX_ALUop), .sw(func), .aluc(aluc_sig));

    wire [31:0] result;
    wire is_zero;

    wire [4:0]  shamt = EX_I[`SHAMT];

    wire [31:0] alu_A_WB, alu_A_MEM;
    Forward forward_alu_A_WB(
        .data0 (EX_A),
        .data1 (WB_data),
        .write (!WB_Bubble && WB_WriteReg),
        .same_addr (WB_reg_dst==EX_I[`RS]),
        .data (alu_A_WB)
    );
    Forward forward_alu_A_MEM(
        .data0 (alu_A_WB),
        .data1 (MEM_data),
        .write (!MEM_Bubble && MEM_WriteReg),
        .same_addr (MEM_reg_dst==EX_I[`RS]),
        .data (alu_A_MEM)
    );

    wire [31:0] alu_B_WB, alu_B_MEM;
    Forward forward_alu_B_WB(
        .data0 (EX_B),
        .data1 (WB_data),
        .write (!WB_Bubble && WB_WriteReg),
        .same_addr (WB_reg_dst==EX_I[`RT]),
        .data (alu_B_WB)
    );
    Forward forward_alu_B_MEM(
        .data0 (alu_B_WB),
        .data1 (MEM_data),
        .write (!MEM_Bubble && MEM_WriteReg),
        .same_addr (MEM_reg_dst==EX_I[`RT]),
        .data (alu_B_MEM)
    );

    wire [31:0] alu_src_B = EX_ALUSrcB ? EX_immed : alu_B_MEM;

    ALU alu0(
        .A (alu_A_MEM),
        .B (alu_src_B),
        .op (aluc_sig),
        .sa (shamt),
        .res (result),
        .o_zf (is_zero)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {MEM_I, MEM_B, MEM_S, MEM_reg_dst, MEM_S_is_zero} <= 0;
            {MEM_MemWrite, MEM_WriteReg, MEM_MemToReg} <= 0;
            MEM_Bubble <= 1;
        end else begin
            MEM_I <= EX_I;
            MEM_B <= EX_B;
            MEM_S <= result;
            MEM_reg_dst <= EX_reg_dst;
            MEM_S_is_zero <= is_zero;
            //signals
            MEM_MemWrite <= EX_MemWrite;
            MEM_WriteReg <= EX_WriteReg;
            MEM_MemToReg <= EX_MemToReg;
            MEM_Bubble <= EX_Bubble;
        end
    end

    assign MEM_data = MEM_S;

    /* ------ mem stage ------- */

    wire [31:0] mem_input_data;
    Forward forward_mem(
        .data0 (MEM_B),
        .data1 (WB_data),
        .write (!WB_Bubble && WB_WriteReg),
        .same_addr (WB_reg_dst==MEM_I[`RT]),
        .data (mem_input_data)
    );

    // Data Memory
    wire [31:0] mem_data;
    DataMem data_mem(
        .addra (MEM_S),
        // Forwarding from WB
        .dina (mem_input_data),
        .clka (~clk),
        .wea (MEM_MemWrite),
        .douta (mem_data)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {WB_I, WB_mem_data, WB_S, WB_reg_dst} <= 0;
            {WB_WriteReg, WB_MemToReg} <= 0;
            WB_Bubble <= 1;
        end else begin
            WB_I <= MEM_I;
            WB_mem_data <= mem_data;
            WB_S <= MEM_S;
            WB_reg_dst <= MEM_reg_dst;
            //signals
            WB_WriteReg <= MEM_WriteReg; // Write
            WB_MemToReg <= MEM_MemToReg;
            WB_Bubble <= MEM_Bubble;
        end
    end

    /* ----- wb stage ----- */

    assign WB_data = WB_MemToReg ? WB_mem_data : WB_S;

    /* ----- display ----- */

    reg [31:0] cnt;
    always @(posedge clk or posedge rst)
        cnt <= rst ? 0 : cnt+32'b1;

    //assign LED = {1, clk, rst, debpb1, SW};
    assign LED = {clk, rst, o_pc[5:0]};

    wire [63:0] reg_asc, I_asc;
    wire [15:0] ID_type_asc, EX_type_asc, MEM_type_asc, WB_type_asc;

    bin2asc_32  b2a0 (C, reg_asc),
                b2a1 (ID_I, I_asc);

    ParseType prsTp0 (ID_I, ID_Bubble, ID_type_asc),
              prsTp1 (EX_I, EX_Bubble, EX_type_asc),
              prsTp2 (MEM_I, MEM_Bubble, MEM_type_asc),
              prsTp3 (WB_I, WB_Bubble, WB_type_asc);

    //always @(posedge clk_lcd) begin
    always @* begin
        str0 <= I_asc;
        str1 <= reg_asc;
        str2[15:0] <= WB_type_asc;
        str2[47:32] <= MEM_type_asc;
        str2[79:64] <= EX_type_asc;
        str2[111:96] <= ID_type_asc;
    end

endmodule
