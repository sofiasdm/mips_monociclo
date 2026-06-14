/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: Unidade Lógica e Aritmética (ULA)
   FUNÇÃO: Executa as operações aritméticas, lógicas, de deslocamento 
   ou de comparação com base nos dados recebidos e na operação ordenada 
   pelo controle.

   EQUIPE:
   - KAUA GABRIEL DOS SANTOS CELESTINO
   - SOFIA DUARTE DE MENDONCA 
   ==================================================================== */

module ula (
    input wire [31:0] In1,       // Operando 1 (geralmente vindo de R[$rs])
    input wire [31:0] In2,       // Operando 2 (vindo de R[$rt] ou do imediato extenso)
    input wire [3:0]  OP,        // Código da operação fornecido por ula_ctrl
    output reg [31:0] result,    // Resultado de 32 bits da operação
    output wire Zero_flag  // Ativado (1) se result == 0, usado em branches
);

    // Definição interna dos códigos de operação (Mapeamento do projetista)
    localparam OP_AND  = 4'b0000;
    localparam OP_OR   = 4'b0001;
    localparam OP_ADD  = 4'b0010;
    localparam OP_SUB  = 4'b0110;
    localparam OP_SLT  = 4'b0111; // Signed comparison
    localparam OP_NOR  = 4'b1100;
    localparam OP_XOR  = 4'b0011;
    localparam OP_SLTU = 4'b0100; // Unsigned comparison
    localparam OP_SLL  = 4'b0101; // Shift Left Logical
    localparam OP_SRL  = 4'b1000; // Shift Right Logical
    localparam OP_SRA  = 4'b1001; // Shift Right Arithmetic

    // Bloco combinacional para determinar o resultado com base no controle OP
    always @(*) begin
        case (OP)
            OP_AND:  result = In1 & In2;                               // AND / ANDI
            OP_OR:   result = In1 | In2;                               // OR / ORI
            OP_ADD:  result = In1 + In2;                               // ADD / ADDI / LW / SW
            OP_SUB:  result = In1 - In2;                               // SUB / BEQ / BNE
            OP_XOR:  result = In1 ^ In2;                               // XOR / XORI
            OP_NOR:  result = ~(In1 | In2);                            // NOR
            OP_SLT:  result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0; // SLT / SLTI
            OP_SLTU: result = (In1 < In2) ? 32'd1 : 32'd0;             // SLTU / SLTIU
            
            // Para shifts por quantidade variável (sllv, srlv, srav), In1 contém o shamt/valor de rs
            OP_SLL:  result = In2 << In1[4:0];                         // SLL / SLLV
            OP_SRL:  result = In2 >> In1[4:0];                         // SRL / SRLV (Unsigned shift)
            OP_SRA:  result = $signed(In2) >>> In1[4:0];               // SRA / SRAV (Signed shift)
            
            default: result = 32'h00000000;
        endcase
    end

    // Atribuição contínua da flag Zero: 1 se o resultado for zero, 0 caso contrário
    assign Zero_flag = (result == 32'h00000000) ? 1'b1 : 1'b0;

endmodule
