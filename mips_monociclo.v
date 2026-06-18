/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: Núcleo MIPS Monociclo (Top-Level)
   FUNÇÃO: Atua como o módulo principal (Top-Level) que interliga todos 
   os componentes do processador através de barramentos de fios (wires).
   
   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */


module mips_monociclo (
    input wire clock,                // Sinal de clock global do sistema
    input wire reset,                // Sinal de reset global do sistema
    output wire [31:0] out_pc,       // Saída monitorizada: Valor atual do PC
    output wire [31:0] out_ula,      // Saída monitorizada: Resultado atual da ULA
    output wire [31:0] out_dmem      // Saída monitorizada: Dado atual da saída da RAM
);

    // =================================================================
    // 1. DECLARAÇÃO DE FIOS INTERNOS (WIRES)
    // =================================================================
    
    // Sinais do PC e Memória de Instrução
    wire [31:0] pc_atual;
    wire [31:0] pc_proximo;
    wire [31:0] pc_mais_4;
    wire [31:0] instrucao;

    // Sinais da Unidade de Controle
    wire [1:0]  reg_dst;
    wire alu_src;
    wire [1:0]  mem_to_reg;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire branch_eq;
    wire branch_n_eq;
    wire [2:0]  alu_op;
    wire jump;
    wire jump_reg;

    // Sinais do Banco de Registradores
    wire  [4:0]  w_reg_addr; // Usado no bloco combinacional interno do jal
    wire [31:0] r_data1;
    wire [31:0] r_data2;
    wire  [31:0] w_reg_data; // Usado no bloco combinacional de retorno

    // Sinais de Extensão e Deslocamento
    wire [31:0] imm_ext;
    wire [31:0] imm_ext_shift;
    wire [31:0] pc_branch;
    wire [31:0] pc_no_jump;

    // Sinais da ULA
    wire [31:0] alu_in2;
    wire [3:0]  ula_control_op;
    wire [31:0] alu_resultado;
    wire zero_flag;

    // Sinais da Memória de Dados
    wire [31:0] ram_read_data;

    // Sinais de cálculo do Jump
    wire [31:0] endereco_jump;
  
    // Sinais booleanos simulando as portas lógicas discretas do hardware
    wire w_and_beq;
    wire w_not_zero;
    wire w_and_bne;
    wire tomar_branch;
  
    // =================================================================
    // 2. INSTANCIAÇÃO DOS MÓDULOS
    // =================================================================

    // Instância do Contador de Programa (PC)
    pc pc_inst (
        .clock(clock),
        .reset(reset),
        .nextPC(pc_proximo),
        .PC(pc_atual)
    );

    // Instância da Memória de Instrução (ROM)
    i_mem i_mem_inst (
        .address(pc_atual),
        .i_out(instrucao)
    );

    // Instância da Unidade de Controle Central
    control control_inst (
        .Opcode(instrucao[31:26]),
        .Func(instrucao[5:0]),
        .RegDst(reg_dst),
        .ALUSrc(alu_src),
        .MemtoReg(mem_to_reg),
        .RegWrite(reg_write),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .BranchEq(branch_eq),
        .BranchNotEq(branch_n_eq),
        .ALUOp(alu_op),
        .Jump(jump),
        .JumpReg(jump_reg)
    );

    // Instância do Banco de Registradores (RegFile)
    regfile regfile_inst (
        .Clock(clock),
        .Reset(reset),
        .ReadAddr1(instrucao[25:21]), // rs
        .ReadAddr2(instrucao[20:16]), // rt
        .WriteAddr(w_reg_addr),
        .WriteData(w_reg_data),
        .RegWrite(reg_write),
        .ReadData1(r_data1),
        .ReadData2(r_data2)
    );

    // Instância do Extensor de Sinal (Trata extensões aritméticas e lógicas)
    // O sinal 'alu_op[1]' descobre se é andi/ori/xori (extensão de zeros) ou restas (sinal)
    sign_extend sign_extend_inst (
        .In(instrucao[15:0]),
        .Ctrl_Ext((alu_op == 3'b011 || alu_op == 3'b100 || alu_op == 3'b101)), 
        .Out(imm_ext)
    );

    // Instância do Controle da ULA
    ula_ctrl ula_ctrl_inst (
        .ALUOp(alu_op),
        .func(instrucao[5:0]),
        .OP(ula_control_op)
    );

    // Instância da Unidade Lógica e Aritmética (ULA)
    wire eh_shift_constante = (instrucao[31:26] == 6'b000000) && (instrucao[25:21] == 5'b00000) &&
                              (instrucao[5:0] == 6'b000000 || instrucao[5:0] == 6'b000010 || instrucao[5:0] == 6'b000011);
	 ula ula_inst (
        .In1(eh_shift_constante ? {27'b0, instrucao[10:6]} : r_data1),
        .In2(alu_in2),
        .OP(ula_control_op),
        .result(alu_resultado),
        .Zero_flag(zero_flag)
    );

    // Instância da Memória de Dados (RAM)
    d_mem d_mem_inst (
	     .clock(clock),
        .Address(alu_resultado),
        .WriteData(r_data2),
        .MemWrite(mem_write),
        .MemRead(mem_read),
        .ReadData(ram_read_data)
    );

    // Instância do Deslocador de Bit para o Branch (Multiplica imm por 4)
    shift_left_2 shift_branch_inst (
        .In(imm_ext),
        .Out(imm_ext_shift)
    );

    // =================================================================
    // 3. LÓGICA COMBINACIONAL INTERMÉDIA (Caminho de Dados)
    // =================================================================

    // Cálculo dos somadores padrão do MIPS
    assign pc_mais_4  = pc_atual + 4;
    assign pc_branch  = pc_mais_4 + imm_ext_shift;
    assign w_and_beq    = branch_eq & zero_flag;      // Porta AND do BEQ
    assign w_not_zero   = ~zero_flag;                 // Porta NOT da flag zero
    assign w_and_bne    = branch_n_eq & w_not_zero;   // Porta AND do BNE

    // MUX: Seleção do Registrador de Destino (RegDst) via atribuição contínua
	 assign w_reg_addr = (reg_dst == 2'b00) ? instrucao[20:16] :
                    (reg_dst == 2'b01) ? instrucao[15:11] :
                    (reg_dst == 2'b10) ? 5'd31 :
                    instrucao[15:11];

    // MUX: Seleção do Dado de Escrita no Banco (MemtoReg) via atribuição contínua
	 assign w_reg_data = (mem_to_reg == 2'b00) ? alu_resultado :
                    (mem_to_reg == 2'b01) ? ram_read_data :
                    (mem_to_reg == 2'b10) ? pc_mais_4 :
                    (mem_to_reg == 2'b11) ? {instrucao[15:0], 16'h0000} :
                    alu_resultado;

    // MUX: Seleção do segundo operando da ULA (ALUSrc)
    assign alu_in2 = (alu_src == 1'b1) ? imm_ext : r_data2;

    // Lógica para decisão de Branch (Condicional)
    assign tomar_branch = (branch_eq && zero_flag) || (branch_n_eq && !zero_flag);
    
    // MUX: Decide se o PC vai para o Branch ou segue PC+4
    assign pc_no_jump = (tomar_branch == 1'b1) ? pc_branch : pc_mais_4;

    // Cálculo do Endereço de Jump Absoluto (Concatenando PC[31:28] com os 26 bits shiftados por 2)
    assign endereco_jump = {pc_mais_4[31:28], instrucao[25:0], 2'b00};

    // MUX Final do PC: Decide entre Caminho Normal/Branch, Jump Incondicional (j/jal) ou Jump Register (jr)
    assign pc_proximo = (jump_reg == 1'b1) ? r_data1 : 
                        (jump     == 1'b1) ? endereco_jump : pc_no_jump;


    // =================================================================
    // 4. ATRIBUIÇÃO DAS SAÍDAS OBRIGATÓRIAS DO PROJETO
    // =================================================================
    assign out_pc    = pc_atual;
    assign out_ula   = alu_resultado;
    assign out_dmem  = ram_read_data;

endmodule
