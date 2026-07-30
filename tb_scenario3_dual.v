module tb_scenario3_dual;
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

        // Initialization
        instructions[0]  = 32'b00100000000001000000000000001000;  // addi $a0, $zero, 8
        instructions[1]  = 32'b00100000000010010000000000000001;  // addi $t1, $zero, 1
        instructions[2]  = 32'b00100000000010110000000000000010;  // addi $t3, $zero, 2
        instructions[3]  = 32'b00100000000010000000000000000101;  // addi $t0, $zero, 5
        instructions[4]  = 32'b00100000000010100000000000000010;  // addi $t2, $zero, 2
        instructions[5]  = 32'b00100000000011000000000000000011;  // addi $t4, $zero, 3
        instructions[6]  = 32'b00100000000011010000000000000100;  // addi $t5, $zero, 4
        instructions[7]  = 32'b00100000000011100000000000000101;  // addi $t6, $zero, 5
        instructions[8]  = 32'b00100000000011110000000000000110;  // addi $t7, $zero, 6
        instructions[9]  = 32'b00100000000110000000000000000111;  // addi $t8, $zero, 7
        instructions[10] = 32'b00100000000110010000000000001000;  // addi $t9, $zero, 8
        instructions[11] = 32'b00100000000000100000000000001001;  // addi $v0, $zero, 9
        instructions[12] = 32'b00100000000000110000000000001010;  // addi $v1, $zero, 10
        instructions[13] = 32'b00100000000100000000000000001011;  // addi $s0, $zero, 11
        instructions[14] = 32'b00100000000100010000000000001100;  // addi $s1, $zero, 12
        instructions[15] = 32'b00100000000100100000000000001101;  // addi $s2, $zero, 13
        instructions[16] = 32'b00100000000100110000000000001110;  // addi $s3, $zero, 14
        instructions[17] = 32'b00100000000101000000000000001111;  // addi $s4, $zero, 15
        instructions[18] = 32'b00100000000101010000000000010000;  // addi $s5, $zero, 16
        instructions[19] = 32'b00100000000101100000000000010001;  // addi $s6, $zero, 17
        instructions[20] = 32'b00100000000101110000000000010010;  // addi $s7, $zero, 18
        instructions[21] = 32'b00000000000000000000000000000000;  // nop

        // loop: (index 22)
        instructions[22] = 32'b00100000100001001111111111111111;  // addi $a0, $a0, -1
        instructions[23] = 32'b00100001000010000000000000000001;  // addi $t0, $t0, 1
        instructions[24] = 32'b00000001010010110101000000100010;  // sub  $t2, $t2, $t3
        instructions[25] = 32'b00000001100010110110000000100100;  // and  $t4, $t4, $t3
        instructions[26] = 32'b00000001101010110110100000100101;  // or   $t5, $t5, $t3
        instructions[27] = 32'b00000001110010110111000000100110;  // xor  $t6, $t6, $t3
        instructions[28] = 32'b00000001111010110111100000100000;  // add  $t7, $t7, $t3
        instructions[29] = 32'b00000011000010111100000000100010;  // sub  $t8, $t8, $t3
        instructions[30] = 32'b00000011001010111100100000100100;  // and  $t9, $t9, $t3
        instructions[31] = 32'b00000000010010110001000000100101;  // or   $v0, $v0, $t3
        instructions[32] = 32'b00000000011010110001100000100110;  // xor  $v1, $v1, $t3
        instructions[33] = 32'b00000010000010111000000000100000;  // add  $s0, $s0, $t3
        instructions[34] = 32'b00000010001010111000100000100010;  // sub  $s1, $s1, $t3
        instructions[35] = 32'b00000010010010111001000000100100;  // and  $s2, $s2, $t3
        instructions[36] = 32'b00000010011010111001100000100101;  // or   $s3, $s3, $t3
        instructions[37] = 32'b00000010100010111010000000100110;  // xor  $s4, $s4, $t3
        instructions[38] = 32'b00000010101010111010100000100000;  // add  $s5, $s5, $t3
        instructions[39] = 32'b00000010110010111011000000100010;  // sub  $s6, $s6, $t3
        instructions[40] = 32'b00000010111010111011100000100100;  // and  $s7, $s7, $t3
        instructions[41] = 32'b00000001001010110100100000100101;  // or   $t1, $t1, $t3
        instructions[42] = 32'b00100001011010110000000000000001;  // addi $t3, $t3, 1
        instructions[43] = 32'b00000001100010000110000000100000;  // add  $t4, $t4, $t0
        instructions[44] = 32'b00000001101010000110100000100010;  // sub  $t5, $t5, $t0
        instructions[45] = 32'b00000001110010000111000000100100;  // and  $t6, $t6, $t0
        instructions[46] = 32'b00000001111010000111100000100101;  // or   $t7, $t7, $t0
        instructions[47] = 32'b00000011000010001100000000100110;  // xor  $t8, $t8, $t0
        instructions[48] = 32'b00000011001010001100100000100000;  // add  $t9, $t9, $t0
        instructions[49] = 32'b00000000010010000001000000100010;  // sub  $v0, $v0, $t0
        instructions[50] = 32'b00000000011010000001100000100100;  // and  $v1, $v1, $t0
        instructions[51] = 32'b00000010000010001000000000100101;  // or   $s0, $s0, $t0
        instructions[52] = 32'b00000010001010001000100000100110;  // xor  $s1, $s1, $t0
        instructions[53] = 32'b00000010010010001001000000100000;  // add  $s2, $s2, $t0
        instructions[54] = 32'b00000010011010001001100000100010;  // sub  $s3, $s3, $t0
        instructions[55] = 32'b00000010100010001010000000100100;  // and  $s4, $s4, $t0
        instructions[56] = 32'b00000010101010001010100000100101;  // or   $s5, $s5, $t0
        instructions[57] = 32'b00000010110010001011000000100110;  // xor  $s6, $s6, $t0
        instructions[58] = 32'b00000010111010001011100000100000;  // add  $s7, $s7, $t0
        instructions[59] = 32'b00000001001010000100100000100010;  // sub  $t1, $t1, $t0
        instructions[60] = 32'b00000001010010000101000000100100;  // and  $t2, $t2, $t0
        instructions[61] = 32'b00000001100010000110000000100101;  // or   $t4, $t4, $t0
        instructions[62] = 32'b00010100100000001111111111010111;  // bnez $a0, loop (target = 22, offset = -41)
        instructions[63] = 32'b00000000000000000000000000000000;  // nop
        instructions[64] = 32'b00000000000000000000000000000000;  // nop
        instructions[65] = 32'b00000000000000000000000000000000;  // nop

        // done: (index 66)
        instructions[66] = 32'b00001000000000000000000001000010;  // j done (target = 66)
        instructions[67] = 32'b00000000000000000000000000000000;  // nop
        instructions[68] = 32'b00000000000000000000000000000000;  // nop
        instructions[69] = 32'b00000000000000000000000000000000;  // nop
        
        last_instr = 67;

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
