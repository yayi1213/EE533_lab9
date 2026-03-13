module ARM_CPU(
    input clk,
    input rst_n
);
    reg [31:0] IM [0:70];
    reg [31:0] DM [0:127];
    reg [31:0] RF [0:15];

    reg [31:0] PC;
    wire [31:0] inst = IM[PC];
    wire [3:0] cond = inst[31:28];
    wire [2:0] opclass = inst[27:25];
    wire       I = inst[25];
    wire [3:0] opcode = inst[24:21];
    wire       L = inst[20];
    wire [3:0] Rn = inst[19:16];
    wire [3:0] Rd = inst[15:12];
    wire [11:0] operand2 = inst[11:0];
    wire [15:0] reglist = inst[15:0];
    wire [23:0] imm = inst[23:0];

    reg [3:0] cond_ID, cond_EX, cond_MEM, cond_WB;
    reg [2:0] opclass_ID, opclass_EX, opclass_MEM, opclass_WB;
    reg       I_ID, I_EX, I_MEM, I_WB;
    reg [3:0] opcode_ID, opcode_EX, opcode_MEM, opcode_WB;
    reg       L_ID, L_EX, L_MEM, L_WB;
    reg [3:0] Rn_ID, Rn_EX, Rn_MEM, Rn_WB;
    reg [3:0] Rd_ID, Rd_EX, Rd_MEM, Rd_WB;
    reg [11:0] operand2_ID, operand2_EX, operand2_MEM, operand2_WB;
    reg [15:0] reglist_ID, reglist_EX, reglist_MEM, reglist_WB;
    reg [23:0] imm_ID, imm_EX;

    reg take, stall;
    reg [31:0] rn_data, rn_data_MEM, rd_data, result, rd_data_MEM, rd_data_WB, result_MEM, result_WB;
    reg [31:0] sp;
    reg valid;
    integer i;
    reg [3:0] comb_index_ld, comb_index_st;
    reg [31:0] tmp_ld_arr_comb [0:15], tmp_ld_arr [0:15];
    reg [31:0] tmp_st_arr_comb [0:15], tmp_st_arr [0:15];
    reg N, V, Z, N_comb, V_comb, Z_comb;
    integer j;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            valid <= 0;
        else 
            valid <= 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            IM[0] <= 32'he92d4800;
            IM[1] <= 32'he28db004;
            IM[2] <= 32'he24dd038;
            IM[3] <= 32'he59f3104;
            IM[4] <= 32'he24bc038;
            IM[5] <= 32'he1a0e003;
            IM[6] <= 32'he8be000f;
            IM[7] <= 32'he8ac000f;
            IM[8] <= 32'he8be000f;
            IM[9] <= 32'he8ac000f;
            IM[10] <= 32'he89e0003;
            IM[11] <= 32'he88c0003;
            IM[12] <= 32'he3a03000;
            IM[13] <= 32'he50b3008;
            IM[14] <= 32'hea00002e;
            IM[15] <= 32'he51b3008;
            IM[16] <= 32'he2833001;
            IM[17] <= 32'he50b300c;
            IM[18] <= 32'hea000024;
            IM[19] <= 32'he51b300c;
            IM[20] <= 32'he1a03103;
            IM[21] <= 32'he2433004;
            IM[22] <= 32'he083300b;
            IM[23] <= 32'he5132034;
            IM[24] <= 32'he51b3008;
            IM[25] <= 32'he1a03103;
            IM[26] <= 32'he2433004;
            IM[27] <= 32'he083300b;
            IM[28] <= 32'he5133034;
            IM[29] <= 32'he1520003;
            IM[30] <= 32'haa000015;
            IM[31] <= 32'he51b300c;
            IM[32] <= 32'he1a03103;
            IM[33] <= 32'he2433004;
            IM[34] <= 32'he083300b;
            IM[35] <= 32'he5133034;
            IM[36] <= 32'he50b3010;
            IM[37] <= 32'he51b3008;
            IM[38] <= 32'he1a03103;
            IM[39] <= 32'he2433004;
            IM[40] <= 32'he083300b;
            IM[41] <= 32'he5132034;
            IM[42] <= 32'he51b300c;
            IM[43] <= 32'he1a03103;
            IM[44] <= 32'he2433004;
            IM[45] <= 32'he083300b;
            IM[46] <= 32'he5032034;
            IM[47] <= 32'he51b3008;
            IM[48] <= 32'he1a03103;
            IM[49] <= 32'he2433004;
            IM[50] <= 32'he083300b;
            IM[51] <= 32'he51b2010;
            IM[52] <= 32'he5032034;
            IM[53] <= 32'he51b300c;
            IM[54] <= 32'he2833001;
            IM[55] <= 32'he50b300c;
            IM[56] <= 32'he51b300c;
            IM[57] <= 32'he3530009;
            IM[58] <= 32'hdaffffd7;
            IM[59] <= 32'he51b3008;
            IM[60] <= 32'he2833001;
            IM[61] <= 32'he50b3008;
            IM[62] <= 32'he51b3008;
            IM[63] <= 32'he3530009;
            IM[64] <= 32'hdaffffcd;
            IM[65] <= 32'he3a03000;
            IM[66] <= 32'he1a00003;
            IM[67] <= 32'he24bd004;
            IM[68] <= 32'he8bd4800;
            IM[69] <= 32'he12fff1e;
            IM[70] <= 32'h0000011c;
        end else begin
            IM[0] <= 32'he92d4800;
            IM[1] <= 32'he28db004;
            IM[2] <= 32'he24dd038;
            IM[3] <= 32'he59f3104;
            IM[4] <= 32'he24bc038;
            IM[5] <= 32'he1a0e003;
            IM[6] <= 32'he8be000f;
            IM[7] <= 32'he8ac000f;
            IM[8] <= 32'he8be000f;
            IM[9] <= 32'he8ac000f;
            IM[10] <= 32'he89e0003;
            IM[11] <= 32'he88c0003;
            IM[12] <= 32'he3a03000;
            IM[13] <= 32'he50b3008;
            IM[14] <= 32'hea00002e;
            IM[15] <= 32'he51b3008;
            IM[16] <= 32'he2833001;
            IM[17] <= 32'he50b300c;
            IM[18] <= 32'hea000024;
            IM[19] <= 32'he51b300c;
            IM[20] <= 32'he1a03103;
            IM[21] <= 32'he2433004;
            IM[22] <= 32'he083300b;
            IM[23] <= 32'he5132034;
            IM[24] <= 32'he51b3008;
            IM[25] <= 32'he1a03103;
            IM[26] <= 32'he2433004;
            IM[27] <= 32'he083300b;
            IM[28] <= 32'he5133034;
            IM[29] <= 32'he1520003;
            IM[30] <= 32'haa000015;
            IM[31] <= 32'he51b300c;
            IM[32] <= 32'he1a03103;
            IM[33] <= 32'he2433004;
            IM[34] <= 32'he083300b;
            IM[35] <= 32'he5133034;
            IM[36] <= 32'he50b3010;
            IM[37] <= 32'he51b3008;
            IM[38] <= 32'he1a03103;
            IM[39] <= 32'he2433004;
            IM[40] <= 32'he083300b;
            IM[41] <= 32'he5132034;
            IM[42] <= 32'he51b300c;
            IM[43] <= 32'he1a03103;
            IM[44] <= 32'he2433004;
            IM[45] <= 32'he083300b;
            IM[46] <= 32'he5032034;
            IM[47] <= 32'he51b3008;
            IM[48] <= 32'he1a03103;
            IM[49] <= 32'he2433004;
            IM[50] <= 32'he083300b;
            IM[51] <= 32'he51b2010;
            IM[52] <= 32'he5032034;
            IM[53] <= 32'he51b300c;
            IM[54] <= 32'he2833001;
            IM[55] <= 32'he50b300c;
            IM[56] <= 32'he51b300c;
            IM[57] <= 32'he3530009;
            IM[58] <= 32'hdaffffd7;
            IM[59] <= 32'he51b3008;
            IM[60] <= 32'he2833001;
            IM[61] <= 32'he50b3008;
            IM[62] <= 32'he51b3008;
            IM[63] <= 32'he3530009;
            IM[64] <= 32'hdaffffcd;
            IM[65] <= 32'he3a03000;
            IM[66] <= 32'he1a00003;
            IM[67] <= 32'he24bd004;
            IM[68] <= 32'he8bd4800;
            IM[69] <= 32'he12fff1e;
            IM[70] <= 32'h0000011c;
        end
    end

    integer k, n, jj;

    function [4:0] popcount16;
        input [15:0] v;
        integer ii;
        begin
            popcount16 = 0;
            for (ii = 0; ii < 16; ii = ii + 1)
                popcount16 = popcount16 + v[ii];
        end
    endfunction

    reg [4:0] cnt_WB, cnt_EX, cnt_MEM;
    always @(*) cnt_WB = popcount16(reglist_WB);
    always @(*) cnt_EX = popcount16(reglist_EX);
    always @(*) cnt_MEM = popcount16(reglist_MEM);

    reg stall_delay, stall_delay_2, stall_delay_3;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            stall_delay <= 0;
            stall_delay_2 <= 0;
            stall_delay_3 <= 0;
        end else begin
            stall_delay <= stall;
            stall_delay_2 <= stall_delay;
            stall_delay_3 <= stall_delay_2;
        end
    end 

    always @(posedge clk) begin
        if((opclass_WB == 3'b0 && opcode_WB == 4'b0 && !L_WB && Rn_WB == 4'b0 && Rd_WB == 4'b0 && operand2_WB == 12'b0)||stall_delay_3) begin
            //RF <= RF;
        end else begin
            if(opclass_WB < 3'd2 && opcode_WB != 4'b1010) //data processing but not cmp need wb
                RF[Rd_WB] <= result_WB;
            else if((opclass_WB == 3'b010 || opclass_WB == 3'b011) && L_WB)
                RF[Rd_WB] <= (!I_WB)? DM[result_WB >> 2]:result_WB;
            else if(opclass_WB == 3'b100) begin
                if(L_WB) begin //ldm_wb
                    RF[Rn_WB] <= (opcode_WB[0])? (RF[Rn_WB] + (cnt_WB << 2)):RF[Rn_WB];
                    for(k=0;k<16;k=k+1)
                        if(reglist_WB[k]) begin
                            RF[k] <= tmp_ld_arr[k];
                        end
                end else begin //stm_wb
                    if(opcode_WB[0]) begin//W bit
                        if(opcode_WB[2])//U
                            RF[Rn_WB] <= RF[Rn_WB] + (cnt_WB << 2);
                        else
                            RF[Rn_WB] <= RF[Rn_WB] - (cnt_WB << 2);
                    end
                end
            end
        end
    end

    always @(*) begin
        comb_index_ld = 0;
        if(opclass_MEM == 3'b100 && L_MEM) begin
            for(i=0;i<16;i=i+1) begin
                if(reglist_MEM[i]) begin
                    tmp_ld_arr_comb[i] = DM[(rn_data_MEM + comb_index_ld) >> 2];
                    comb_index_ld = comb_index_ld + 4;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            for(j=0;j<16;j=j+1)
                tmp_ld_arr[j] <= 0;
        else if(opclass_MEM == 3'b100 && L_MEM) begin
            for(j=0;j<16;j=j+1)
                tmp_ld_arr[j] <= tmp_ld_arr_comb[j];
        end
    end

    integer m;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            for(m=0;m<16;m=m+1)
                tmp_st_arr[m] <= 0;
        else if(opclass_ID == 3'b100 && !L_ID) begin
            for(m=0;m<16;m=m+1)
                if(reglist_ID[m])
                    tmp_st_arr[m] <= RF[m];
        end else if(opclass_EX == 3'b100 && !L_EX) begin//forwarding as there is dependencies w previous ld
            for(m=0;m<16;m=m+1)
                if(reglist_EX[m] && reglist_MEM[m])
                    tmp_st_arr[m] <= tmp_ld_arr_comb[m];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            sp <= 0;
        else if(opclass_ID == 3'b100)//
            sp <= RF[Rn_ID];
        else if(opclass_EX == 3'b100)
            sp <= sp - (cnt_EX << 2);////////////
        //else if()
    end

    integer o;
    always @(*) begin
        comb_index_st = 0;
        if(opclass_MEM == 3'b100 && !L_MEM) begin
            for(o=0;o<16;o=o+1)
                if(reglist_MEM[o]) begin
                    tmp_st_arr_comb[comb_index_st]= tmp_st_arr[o];
                    comb_index_st = comb_index_st + 1;
                end
        end
    end

    wire wb_rf_rd;
    assign wb_rf_rd = !stall_delay_3 && ((opclass_WB < 3'd2 && opcode_WB != 4'b1010) || (opclass_WB[2:1] == 2'b01 && L_WB) || (opclass_WB == 3'b100 || L_WB));


    always @(posedge clk) begin
        if((opclass_MEM == 3'b0 && opcode_MEM == 4'b0 && !L_MEM && Rn_MEM == 4'b0 && Rd_MEM == 4'b0 && operand2_MEM == 12'b0)||stall_delay_2) begin
            //DM <= DM;
        end else begin
            if(opclass_MEM == 3'b100 && !L_MEM) begin
                for(jj=0;jj<cnt_MEM;jj=jj+1) begin
                    if(!opcode_MEM[2])//U bit inst[20]
                        DM[(RF[Rn_MEM] >> 2) -2 + jj] <= tmp_st_arr_comb[jj];/////
                    else
                        DM[(RF[Rn_MEM] >> 2) + jj] <= tmp_st_arr_comb[jj];
                end
            end else if(opclass_MEM == 3'b010 && !L_MEM) begin
                if(Rn_MEM == Rd_WB && wb_rf_rd)
                    DM[(result_WB - operand2_MEM) >> 2] <= ((Rd_MEM == Rd_WB)&&wb_rf_rd)? ((opclass_WB < 3'd2 )? result_WB:DM[result_WB >> 2]):RF[Rd_MEM];
                else
                    DM[(RF[Rn_MEM] - operand2_MEM) >> 2] <= ((Rd_MEM == Rd_WB)&&wb_rf_rd)? ((opclass_WB < 3'd2 )? result_WB:DM[result_WB >> 2]):RF[Rd_MEM];

            end
        end
    end
 
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            PC <= 0;
        else if(valid) begin
            if(stall)
                PC <= PC;
            else if(take)//branch
                PC <= PC + {{8{imm_EX[23]}}, imm_EX};////////////////
            else
                PC <= PC + 1;
        end
    end

    always @(*) begin
        N_comb = result[31];
        Z_comb = (result == 32'b0)? 1:0;
        if(Rn_EX == Rn_MEM)////////////////////////////////////////////////////
            V_comb = (sp[31] && !result[31]);
        else
            V_comb = (rn_data[31] && !result[31]);
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            N <= 0;
            Z <= 0;
            V <= 0;
        end else if(opclass_EX < 3'd2 && opcode_EX == 4'b1010) begin//CMP
            N <= N_comb;
            Z <= Z_comb;
            V <= V_comb;
        end
    end

    always @(*) begin
        take = ((cond_EX == 4'he) && opclass_EX == 3'b101) || ((cond_EX == 4'ha) && (N == V)) || ((cond_EX == 4'hd) && (Z || (N != V)));//b or bge or ble
    end

    always @(*) begin
        if(!stall_delay)
            stall = (Rn_ID == Rd_EX) && (opclass_EX == 3'b100 || opclass_EX[2:1] == 01) && L_EX && (cond_ID == 4'he);
        else
            stall = 0;
    end 

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cond_ID <= 0;
            opclass_ID <= 0;
            I_ID <= 0;
            opcode_ID <= 0;
            L_ID <= 0;
            Rn_ID <= 0;
            Rd_ID <= 0;
            operand2_ID <= 0;
            reglist_ID <= 0;
            imm_ID <= 0;

            cond_EX <= 0;
            opclass_EX <= 0;
            I_EX <= 0;
            opcode_EX <= 0;
            L_EX <= 0;
            Rn_EX <= 0;
            Rd_EX <= 0;
            reglist_EX <= 0;
            operand2_EX <= 0;
            imm_EX <= 0;
        end else if(take) begin
            cond_ID <= 0;
            opclass_ID <= 0;
            I_ID <= 0;
            opcode_ID <= 0;
            L_ID <= 0;
            Rn_ID <= 0;
            Rd_ID <= 0;
            operand2_ID <= 0;
            reglist_ID <= 0;
            imm_ID <= 0;

            cond_EX <= 0;
            opclass_EX <= 0;
            I_EX <= 0;
            opcode_EX <= 0;
            L_EX <= 0;
            Rn_EX <= 0;
            Rd_EX <= 0;
            operand2_EX <= 0;
            reglist_EX <= 0;
            imm_EX <= 0;
        end else if(!stall) begin
            cond_ID <= cond;
            opclass_ID <= opclass;
            I_ID <= I;
            opcode_ID <= opcode;
            L_ID <= L;
            Rn_ID <= Rn;
            Rd_ID <= Rd;
            operand2_ID <= operand2;
            reglist_ID <= reglist;
            imm_ID <= imm;

            cond_EX <= cond_ID;
            opclass_EX <= opclass_ID;
            I_EX <= I_ID;
            opcode_EX <= opcode_ID;
            L_EX <= L_ID;
            Rn_EX <= Rn_ID;
            Rd_EX <= Rd_ID;
            operand2_EX <= operand2_ID;
            reglist_EX <= reglist_ID;
            imm_EX <= imm_ID;
        end else if(stall) begin
            cond_ID <= cond_ID;
            opclass_ID <= opclass_ID;
            I_ID <= I_ID;
            opcode_ID <= opcode_ID;
            L_ID <= L_ID;
            Rn_ID <= Rn_ID;
            Rd_ID <= Rd_ID;
            operand2_ID <= operand2_ID;
            reglist_ID <= reglist_ID;
            imm_ID <= imm_ID;

            cond_EX <= cond_ID;
            opclass_EX <= opclass_ID;
            I_EX <= I_ID;
            opcode_EX <= opcode_ID;
            L_EX <= L_ID;
            Rn_EX <= Rn_ID;
            Rd_EX <= Rd_ID;
            operand2_EX <= operand2_ID;
            reglist_EX <= reglist_ID;
            imm_EX <= imm_ID;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cond_MEM <= 0;
            opclass_MEM <= 0;
            I_MEM <= 0;
            opcode_MEM <= 0;
            L_MEM <= 0;
            Rn_MEM <= 0;
            Rd_MEM <= 0;
            operand2_MEM <= 0;
            reglist_MEM <= 0;

            cond_WB <= 0;
            opclass_WB <= 0;
            I_WB <= 0;
            opcode_WB <= 0;
            L_WB <= 0;
            Rn_WB <= 0;
            Rd_WB <= 0;
            operand2_WB <= 0;
            reglist_WB <= 0;
        end else begin// if(!stall) begin
            cond_MEM <= cond_EX;
            opclass_MEM <= opclass_EX;
            I_MEM <= I_EX;
            opcode_MEM <= opcode_EX;
            L_MEM <= L_EX;
            Rn_MEM <= Rn_EX;
            Rd_MEM <= Rd_EX;
            operand2_MEM <= operand2_EX;
            reglist_MEM <= reglist_EX;

            cond_WB <= cond_MEM;
            opclass_WB <= opclass_MEM;
            I_WB <= I_MEM;
            opcode_WB <= opcode_MEM;
            L_WB <= L_MEM;
            Rn_WB <= Rn_MEM;
            Rd_WB <= Rd_MEM;
            operand2_WB <= operand2_MEM;
            reglist_WB <= reglist_MEM;
        end 
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rn_data <= 0;
            rd_data <= 0;
        end else begin
            if(PC > 1) 
                rn_data <= (Rn_ID == Rd_EX && !stall_delay)? result:(operand2_ID[3:0] == Rd_MEM)? result_MEM:(Rn_ID == Rd_WB)? result_WB:RF[Rn_ID];
            else
                rn_data <= RF[Rn_ID];
            rd_data <= RF[Rd_ID];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rn_data_MEM <= 0;

            rd_data_MEM <= 0;
            rd_data_WB <= 0;

            result_MEM <= 0;
            result_WB <= 0;
        end else begin
            rn_data_MEM <= (Rn_EX == Rn_WB && (opclass_WB == 3'b100))? rn_data + (cnt_WB << 2):rn_data;

            rd_data_MEM <= rd_data;
            rd_data_WB <= rd_data_MEM;

            result_MEM <= result;
            result_WB <= result_MEM;
        end
    end

    reg check_s1_rn_in_ex;//check senior(mem stage) in ex stage
    always @(*) begin
        check_s1_rn_in_ex = ((opclass_MEM[2:1] == 01) || (opclass_MEM == 3'b100)) && opcode_MEM[0];//((ldr||str)||(ldm/stm))&&W
    end
    reg check_s1_rd_in_ex;//check senior(mem stage) in ex stage
    always @(*) begin
        check_s1_rd_in_ex = (opclass_MEM < 3'd2 && opcode_MEM != 4'b1010) || (opclass_MEM[2:1] == 1'b01 && L_MEM) || (opclass_MEM == 3'b100 && L_MEM && reglist[Rn_EX]);//data_processing except CMP || ldr || (ldm&& in reglist)
    end

    reg check_s2_rn_in_ex;//check senior2(mem stage) in ex stage
    always @(*) begin
        check_s2_rn_in_ex = ((opclass_WB[2:1] == 01) || (opclass_WB == 3'b100)) && opcode_WB[0];//((ldr||str)||(ldm/stm))&&W
    end
    reg check_s2_rd_in_ex;//check senior2(mem stage) in ex stage
    always @(*) begin
        check_s2_rd_in_ex = (opclass_WB < 3'd2 && opcode_WB != 4'b1010) || (opclass_WB[2:1] == 1'b01 && L_WB) || (opclass_WB == 3'b100 && L_WB && reglist[Rn_EX]);//data_processing except CMP || ldr || (ldm&& in reglist)
    end

    reg [4:0] shift;
    reg [31:0] rm_data;
    always @(*) begin
        if(opclass_EX < 2) begin
            case(opcode_EX)
                4'b0010://SUB
                    if(I_EX)
                        result = ((check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)||((opclass_WB == 3'b100) && (Rn_EX == Rn_WB) && opcode_WB[0]))? (sp - {20'b0, operand2_EX}):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM - {20'b0, operand2_EX}):(rn_data - {20'b0, operand2_EX});
                    else
                        result = (check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)? (sp - RF[operand2_EX[3:0]]):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM - RF[operand2_EX[3:0]]):(rn_data - RF[operand2_EX[3:0]]);
                4'b0100://ADD
                    if(I_EX)
                        result = (check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)? (sp + {20'b0, operand2_EX}):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM + {20'b0, operand2_EX}):(stall_delay_2 && opclass_EX < 3'd2 && Rn_EX == Rd_WB && opclass_WB == 3'd2 && opcode_EX == 4'b0100)? (DM[result_WB >> 2] + {20'b0, operand2_EX}):(rn_data + {20'b0, operand2_EX});
                    else
                        result = (check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)? (sp + RF[operand2_EX[3:0]]):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM + RF[operand2_EX[3:0]]):(rn_data + RF[operand2_EX[3:0]]);
                4'b1101: begin//MOV
                    if(operand2_EX[11:4] != 8'b0) begin//shift
                        result = (operand2_EX[3:0] == Rd_MEM && check_s1_rd_in_ex)? (DM[result_MEM >> 2] << (operand2_EX[11:7])):(RF[operand2_EX[3:0]] << (operand2_EX[11:7]));
                        //rm_data = RF[operand2_EX[3:0]];
                        //shift = operand2_EX[11:7];
                    end else begin
                        if(!I_EX)
                            result = (operand2_EX[3:0] == Rd_WB && check_s2_rd_in_ex)? DM[result_WB >> 2]:DM[(RF[operand2_EX[3:0]] >> 2)];
                        else
                            result = {20'b0, operand2_EX};
                    end
                end
                4'b1010://CMP
                    if(I_EX)
                        result = DM[result_WB >> 2]- {20'b0, operand2_EX};
                        //result = (check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)? (sp - {20'b0, operand2_EX}):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM - {20'b0, operand2_EX}):(rn_data - {20'b0, operand2_EX});//update NZCV
                    else
                        result = (operand2_EX[3:0] == Rd_MEM && check_s1_rd_in_ex)? (RF[Rn_EX] - DM[result_MEM >> 2]):(RF[Rn_EX] - RF[operand2_EX[3:0]]);
            endcase
        end else if(opclass_EX == 3'b010)
            if(opcode_EX[2])//U
                result = (Rn_EX == 15)? ((PC << 2) + {20'b0, operand2_EX}):(check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)? (sp + {20'b0, operand2_EX}):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM + {20'b0, operand2_EX}):((rn_data + {20'b0, operand2_EX}));
            else
                result = (Rn_EX == 15)? ((PC << 2) - {20'b0, operand2_EX}):(check_s1_rn_in_ex && Rn_EX == Rn_MEM && !stall_delay_2)? (sp - {20'b0, operand2_EX}):(check_s1_rd_in_ex && Rn_EX == Rd_MEM && !stall_delay_2)? (result_MEM - {20'b0, operand2_EX}):((rn_data - {20'b0, operand2_EX}));
        else if(opclass_EX == 3'b011) begin

        end
    end
    wire [31:0] comb_result, aa, bb;
    wire signed [31:0] tmp;
    assign aa = RF[Rn_EX];
    assign bb = DM[result_MEM >> 2];
    assign comb_result = (RF[Rn_ID] - DM[result_MEM >> 2]);
    assign tmp = 32'd2-(-32'd455);
    wire [31:0] comb_rn_data;
    assign comb_rn_data = RF[Rn_ID];
    wire [31:0] if_stall_result;
    assign if_stall_result = (stall_delay_2 && opclass_EX < 3'd2 && Rn_EX == Rd_WB && opclass_WB == 3'd2 && opcode_EX == 4'b0100)? DM[result_WB >> 2]:0;
    wire cmp_imm;
    assign cmp_imm = (opclass_EX < 3'd2) && (opcode_EX == 4'b1010) && I_EX;


endmodule