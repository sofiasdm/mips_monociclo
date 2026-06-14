/* ====================================================================
   ATIVIDADE: Projeto 02 - Implementação de MIPS Monociclo em Verilog
   COMPONENTE: Unidade de Controle Central (CONTROL)
   ARQUIVO: control.v
   ==================================================================== */

module control (
    input wire [5:0] Opcode,      // 6 bits mais significativos da instrução (bits [31:26])
    input wire [5:0] Func,        // 6 bits menos significativos (campo funct, usado para identificar jr)
    output reg [1:0] RegDst,      // Seleciona o registrador de destino (00=$rt, 01=$rd, 10=$ra para jal)
    output reg ALUSrc,      // Seleciona o segundo operando da ULA (0=RegData2, 1=Imediato)
    output reg [1:0] MemtoReg,    // Seleciona o dado que vai p/ o RegFile (00=ULA, 01=RAM, 10=PC+8 para jal)
    output reg RegWrite,    // Habilita a escrita no Banco de Registradores
    output reg MemRead,     // Habilita a leitura na Memória de Dados
    output reg MemWrite,    // Habilita a escrita na Memória de Dados
    output reg BranchEq,    // Ativado para a instrução BEQ
    output reg BranchNotEq, // Ativado para a instrução BNE
    output reg [2:0] ALUOp,       // Código de operação enviado para o bloco ula_ctrl
    output reg Jump,        // Ativado para salto incondicional (j, jal)
    output reg JumpReg      // Ativado para salto via registrador (jr)
);

    // Bloco combinacional para decodificação do Opcode
    always @(*) begin
        // Valores padrão (Default) para evitar travas (latches) indesejadas
        RegDst      = 2'b00;
        ALUSrc      = 1'b0;
        MemtoReg    = 2'b00;
        RegWrite    = 1'b0;
        MemRead     = 1'b0;
        MemWrite    = 1'b0;
        BranchEq    = 1'b0;
        BranchNotEq = 1'b0;
        ALUOp       = 3'b000;
        Jump        = 1'b0;
        JumpReg     = 1'b0;

        case (Opcode)
            // --------------------------------------------------------
            // INSTRUÇÕES TIPO R (add, sub, and, or, xor, nor, slt, sltu, shifts, jr)
            // --------------------------------------------------------
            6'b000000: begin
                if (Func == 6'b001000) begin
                    // Caso específico da instrução 'jr' (Jump Register)
                    JumpReg  = 1'b1;
                    RegWrite = 1'b0; // JR não escreve no banco de registradores
                end else begin
                    // Demais instruções Tipo R convencionais
                    RegDst   = 2'b01; // Destino é o registrador $rd
                    RegWrite = 1'b1; // Habilita escrita no banco
                    ALUOp    = 3'b010; // Modo Tipo-R no controle da ULA
                end
            end

            // --------------------------------------------------------
            // INSTRUÇÕES TIPO I (Aritméticas e Lógicas com Imediato)
            // --------------------------------------------------------
            6'b001000: begin // addi
                ALUSrc   = 1'b1;   // Usa o imediato estendido por sinal
                RegWrite = 1'b1;   // Escreve o resultado em $rt
                ALUOp    = 3'b000; // Força soma na ULA
            end
            
            6'b001100: begin // andi
                ALUSrc   = 1'b1;   // Usa o imediato estendido por zero
                RegWrite = 1'b1;   // Escreve o resultado em $rt
                ALUOp    = 3'b011; // Força AND na ULA
            end
            
            6'b001101: begin // ori
                ALUSrc   = 1'b1;   // Usa o imediato estendido por zero
                RegWrite = 1'b1;   // Escreve o resultado em $rt
                ALUOp    = 3'b100; // Força OR na ULA
            end
            
            6'b001110: begin // xori
                ALUSrc   = 1'b1;   // Usa o imediato estendido por zero
                RegWrite = 1'b1;   // Escreve o resultado em $rt
                ALUOp    = 3'b101; // Força XOR na ULA
            end
            
            6'b001010: begin // slti
                ALUSrc   = 1'b1;   // Usa o imediato
                RegWrite = 1'b1;   
                ALUOp    = 3'b110; // Força comparação com sinal (SLT)
            end
            
            6'b001011: begin // sltiu
                ALUSrc   = 1'b1;   
                RegWrite = 1'b1;   
                ALUOp    = 3'b111; // Força comparação sem sinal (SLTU)
            end

            6'b001111: begin // lui
                ALUSrc   = 1'b1;   // Pega o imediato
                RegWrite = 1'b1;   
                MemtoReg = 2'b11;  // Sinal especial mapeado no MUX do top-level para fazer shift do imm
            end

            // --------------------------------------------------------
            // INSTRUÇÕES TIPO I (Acesso à Memória de Dados)
            // --------------------------------------------------------
            6'b100011: begin // lw (Load Word)
                ALUSrc   = 1'b1;   // Calcula endereço: base + offset
                MemtoReg = 2'b01;  // O dado gravado no RegFile vem da RAM
                RegWrite = 1'b1;   // Habilita escrita no banco
                MemRead  = 1'b1;   // Ativa leitura da RAM
                ALUOp    = 3'b000; // Força soma para calcular endereço
            end
            
            6'b101011: begin // sw (Store Word)
                ALUSrc   = 1'b1;   // Calcula endereço: base + offset
                MemWrite = 1'b1;   // Ativa escrita na RAM
                ALUOp    = 3'b000; // Força soma para calcular endereço
            end

            // --------------------------------------------------------
            // INSTRUÇÕES TIPO I (Desvios Condicionais / Branches)
            // --------------------------------------------------------
            6'b000100: begin // beq (Branch Equal)
                BranchEq = 1'b1;   // Ativa flag de branch condicional igual
                ALUOp    = 3'b001; // Força subtração na ULA para testar igualdade
            end
            
            6'b000101: begin // bne (Branch Not Equal)
                BranchNotEq = 1'b1;   // Ativa flag de branch condicional diferente
                ALUOp       = 3'b001; // Força subtração na ULA para testar igualdade
            end

            // --------------------------------------------------------
            // INSTRUÇÕES TIPO J (Saltos Incondicionais)
            // --------------------------------------------------------
            6'b000010: begin // j (Jump)
                Jump = 1'b1; // Ativa controle de salto pseudo-absoluto
            end
            
            6'b000011: begin // jal (Jump and Link)
                Jump     = 1'b1;   // Ativa controle de salto
                RegDst   = 2'b10;  // Seleciona o registrador $ra (31)
                MemtoReg = 2'b10;  // Seleciona PC+4 para salvar no banco
                RegWrite = 1'b1;   // Escreve no banco de registradores
            end

            default: begin
                // Caso encontre uma instrução inválida/não mapeada
                RegWrite = 1'b0;
                MemWrite = 1'b0;
            end
        endcase
    end

endmodule