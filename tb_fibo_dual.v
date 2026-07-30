module tb_dual_issue_fixed;
    reg clk, rst, Jen;
    reg [31:0] instructions[512];
    reg [31:0] data_mem[512];

    reg [31:0] Jin;
    wire [31:0] Jout;
    wire InstDone1, InstDone2; 
    wire [31:0] R[32];
    assign R[0] = 0;

    reg [31:0] inst_reg;
    reg [4:0] inst_rs, inst_rt, inst_rd;
    reg [31:0] val_rs, val_rt;
    reg [15:0] inst_imm;
    reg [31:0] inst_imm_sext;
    
    reg [8:0] ipc;
    reg [8:0] pending_branch_target;
    integer delay_slots_remaining;

    
    reg [31:0] ireg[32];
    reg [31:0] ireghi, ireglo;
    reg [31:0] data_addr;

    wire [31:0] Total_Clock_Cycles;
    wire [31:0] Total_Issued_Instructions;
    wire [31:0] Total_Stalls;

    task write2reg(input [4:0] reg_dest, input [31:0] val);
        begin
            if (reg_dest !== 0) ireg[reg_dest] = val;
        end
    endtask

    function [31:0] sra(input [31:0] a, input [4:0] b);
        begin
            sra = ({{32{a[31]}}, a} >> b);
        end
    endfunction

    task exec_internal;
        begin
            inst_reg = instructions[ipc];
            
            ipc = ipc + 1;
            
            if (delay_slots_remaining > 0) begin
                delay_slots_remaining = delay_slots_remaining - 1;
                // apply jump/branch
                if (delay_slots_remaining == 0) begin
                    ipc = pending_branch_target;
                end
            end

            inst_rs = inst_reg[25:21];
            inst_rt = inst_reg[20:16];
            inst_rd = inst_reg[15:11];
            inst_imm = inst_reg[15:0];
            inst_imm_sext = {{16{inst_imm[15]}}, inst_imm};
            val_rs = ireg[inst_rs];
            val_rt = ireg[inst_rt];
            
            case (inst_reg[31:26])
                6'b000000: begin  // RType
                    case (inst_reg[5:0])
                        6'b100000: write2reg(inst_rd, val_rs + val_rt);  // add
                        6'b100010: write2reg(inst_rd, val_rs - val_rt);  // sub
                        6'b100100: write2reg(inst_rd, val_rs & val_rt);  // and
                        6'b100101: write2reg(inst_rd, val_rs | val_rt);  // or
                        6'b100110: write2reg(inst_rd, val_rs ^ val_rt);  // xor
                        6'b000100: write2reg(inst_rd, val_rs << val_rt[4:0]);  // sll
                        6'b000110: write2reg(inst_rd, val_rs >> val_rt[4:0]);  // srl
                        6'b000111: write2reg(inst_rd, sra(val_rs, val_rt[4:0]));  // sra
                        6'b001000: begin // jr 
                            pending_branch_target = val_rs;
                            delay_slots_remaining = 3;
                        end
                        6'b000000: write2reg(inst_rd, val_rt << inst_reg[10:6]);  // sll (imm)
                        6'b011010: begin  // div HI=rs%rt; LO=rs/rt
                            ireghi = val_rs % val_rt;
                            ireglo = val_rs / val_rt;
                        end
                        6'b010000: write2reg(inst_rd, ireghi);  // mfhi
                        6'b010010: write2reg(inst_rd, ireglo);  // mflo
                        default $display("NOT IMPLEMENTED : rtype[func: %b]", inst_reg[5:0]);
                    endcase
                end
                6'b000011: begin  // jal 
                    write2reg(31, ipc); // Saves return address 
                    pending_branch_target = inst_reg[25:0];      
                    delay_slots_remaining = 3;
                end
                6'b001000: write2reg(inst_rt, val_rs + inst_imm_sext);  // addi
                6'b101011: begin  // sw
                    data_addr = val_rs + inst_imm_sext;
                    if (data_addr & 3 !== 0)
                        $display("WARNING : Unaligned data address (%x)", data_addr);
                    data_mem[(data_addr>>2)&511] = val_rt;
                end
                6'b100011: begin  // lw
                    data_addr = val_rs + inst_imm_sext;
                    if (data_addr & 3 !== 0)
                        $display("WARNING : Unaligned data address (%x)", data_addr);
                    write2reg(inst_rt, data_mem[(data_addr>>2)&511]);
                end
                6'b000101: begin  // bne
                    if (val_rs != val_rt) begin
                        pending_branch_target = ipc + inst_imm_sext;
                        delay_slots_remaining = 3;
                    end
                end
                6'b001010: write2reg(inst_rt, val_rs < inst_imm_sext ? 1 : 0);  // slti
                6'b000010: begin // j 
                    pending_branch_target = inst_imm; 
                    delay_slots_remaining = 3;
                end
                default $display("NOT IMPLEMENTED : [opcode: %b]", inst_reg[31:26]);
            endcase
        end
    endtask

    main _main (
        .clk(clk),
        .rst(rst),
        .Jen(Jen),
        .Jin(Jin),
        .Jout(Jout),
        .InstDone1(InstDone1),
        .InstDone2(InstDone2),
        .R1(R[1]), .R2(R[2]), .R3(R[3]), .R4(R[4]), .R5(R[5]),
        .R6(R[6]), .R7(R[7]), .R8(R[8]), .R9(R[9]), .R10(R[10]),
        .R11(R[11]), .R12(R[12]), .R13(R[13]), .R14(R[14]), .R15(R[15]),
        .R16(R[16]), .R17(R[17]), .R18(R[18]), .R19(R[19]), .R20(R[20]),
        .R21(R[21]), .R22(R[22]), .R23(R[23]), .R24(R[24]), .R25(R[25]),
        .R26(R[26]), .R27(R[27]), .R28(R[28]), .R29(R[29]), .R30(R[30]),
        .R31(R[31]),
        .Total_Clock_Cycles(Total_Clock_Cycles),
        .Total_Issued_Instructions(Total_Issued_Instructions),
        .Total_Stalls(Total_Stalls)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    int i, j;
    int last_instr;
    int fail_flag;

    initial begin
        for (i = 0; i < 512; i++) instructions[i] = 0;
        for (i = 0; i < 512; i++) data_mem[i] = 0;
        for (i = 0; i < 32; i++) ireg[i] = 0;
        ireghi = 0;
        ireglo = 0;
        
        ipc = 0;
        delay_slots_remaining = 0;
        fail_flag = 0;

        instructions[0]  = 32'b00100000000111010000100000000000;  // addi (I)  | $sp = $zero + 2048
        instructions[1]  = 32'b00000000000000000100000000100000;  // add  (R)  | $t0 = $zero + $zero
        instructions[2]  = 32'b00100000000010010000000000000001;  // addi (I)  | $t1 = $zero + 1
        instructions[3]  = 32'b00100000000001000000000000001000;  // addi (I)  | $a0 = $zero + 8
        instructions[4]  = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[5]  = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[6]  = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[7]  = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[8]  = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[9]  = 32'b00000000000000000000000000000000;  // nop  (R)
        // loop: (index 10)
        instructions[10] = 32'b00000001000010010001000000100000;  // add  (R)  | $v0 = $t0 + $t1
        instructions[11] = 32'b00000001001000000100000000100000;  // add  (R)  | $t0 = $t1 + $zero
        instructions[12] = 32'b00100000100001001111111111111111;  // addi (I)  | $a0 = $a0 - 1
        instructions[13] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[14] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[15] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[16] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[17] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[18] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[19] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[20] = 32'b00000000010000000100100000100000;  // add  (R)  | $t1 = $v0 + $zero
        instructions[21] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[22] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[23] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[24] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[25] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[26] = 32'b00010100100000001111111111101111;  // bne  (I)  | bnez $a0, loop (target=10, PC+1=27, offset=-17)
        instructions[27] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[28] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[29] = 32'b00000000000000000000000000000000;  // nop  (R)
        // done: (index 30)
        instructions[30] = 32'b00001000000100000000000000011110;  // j    (J)  | j done (target = 30)
        instructions[31] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[32] = 32'b00000000000000000000000000000000;  // nop  (R)
        instructions[33] = 32'b00000000000000000000000000000000;  // nop  (R)
        
        last_instr = 31;

        rst = 1;
        #8 rst = 0;
        Jen = 1;
        for (i = 0; i < 512; i++) begin  // D mem load
            Jin = data_mem[511-i];
            #2;
        end
        for (i = 0; i < 512; i++) begin  // I mem load
            Jin = instructions[511-i];
            #2;
        end
        Jen = 0;
        
        rst = 1;
        #2 rst = 0;  

        #8;
        while (ipc < last_instr && !fail_flag) begin
            #2;
            
            if (InstDone1 === 1'b1 || InstDone2 === 1'b1) begin
                
                if (InstDone1 === 1'b1) begin
                    $display("ipc Lane A : ", ipc);
                    exec_internal();
                end
                
                if (InstDone2 === 1'b1) begin
                    $display("ipc Lane B : ", ipc);
                    exec_internal();
                end

                for (j = 1; j < 32; j++) begin
                    if (R[j] !== ireg[j]) begin
                        fail_flag = 1; 
                        $display("failed at %d, Expected=%x, Found=%x", j, ireg[j], R[j]);
                    end
                end
                
                if (fail_flag) begin
                    $display("Expectation : ", " [1]%x", ireg[1], " [2]%x", ireg[2], " [3]%x",
                        ireg[3], " [4]%x", ireg[4], " [5]%x", ireg[5],
                        " [6]%x", ireg[6], " [7]%x", ireg[7],
                        " [8]%x", ireg[8], " [9]%x", ireg[9], " [10]%x", ireg[10], " [11]%x", ireg[11],
                        " [12]%x", ireg[12], " [13]%x", ireg[13], " [14]%x", ireg[14], " [15]%x", ireg[15], 
                        " [16]%x", ireg[16], " [17]%x", ireg[17], " [18]%x", ireg[18],
                        " [19]%x", ireg[19], " [20]%x", ireg[20], " [21]%x", ireg[21], " [22]%x", ireg[22], 
                        " [23]%x", ireg[23], " [24]%x", ireg[24], " [25]%x", ireg[25],
                        " [26]%x", ireg[26], " [27]%x", ireg[27], " [28]%x", ireg[28],
                        " [29]%x", ireg[29], " [30]%x", ireg[30], " [31]%x", ireg[31]);
                    
                    $display("Reality     : ", " [1]%x", R[1], " [2]%x", R[2], " [3]%x", R[3],
                        " [4]%x", R[4], " [5]%x", R[5], " [6]%x", R[6], " [7]%x", R[7],
                        " [8]%x", R[8], " [9]%x", R[9], " [10]%x", R[10], " [11]%x", R[11],
                        " [12]%x", R[12], " [13]%x", R[13], " [14]%x", R[14], " [15]%x", R[15],
                        " [16]%x", R[16], " [17]%x", R[17], " [18]%x", R[18], " [19]%x", R[19],
                        " [20]%x", R[20], " [21]%x", R[21], " [22]%x", R[22], " [23]%x", R[23],
                        " [24]%x", R[24], " [25]%x", R[25], " [26]%x", R[26], " [27]%x", R[27],
                        " [28]%x", R[28],
                        " [29]%x", R[29], " [30]%x", R[30], " [31]%x", R[31]);
                    $display("FAILED");
                end
            end
        end

        if (!fail_flag) begin
            $display("Total Clock Cycles: %d", Total_Clock_Cycles);
            $display("Total Issued Instructions: %d", Total_Issued_Instructions);
            $display("Total Stalls: %d", Total_Stalls);
            $display("ACCEPTED");
        end

        $finish(0);
    end
endmodule
