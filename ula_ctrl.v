/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: ula_ctrl
   FUNÇÃO: Combina o sinal de controle geral com o campo funct da 
   instrução para deduzir a operação matemática exata que a ULA deve fazer.

   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */

module ula_ctrl (
    input wire [2:0] ALUOp,  // Sinal de controle vindo da unidade central (expandido para 3 bits)
    input wire [5:0] func,   // 6 bits menos significativos da instrução (campo funct)
    output reg [3:0] OP      // Código de operação de 4 bits enviado para a ULA
);

    // Códigos de saída da ULA correspondentes ao arquivo ula.v
    localparam OP_AND  = 4'b0000;
    localparam OP_OR   = 4'b0001;
    localparam OP_ADD  = 4'b0010;
    localparam OP_SUB  = 4'b0110;
    localparam OP_SLT  = 4'b0111;
    localparam OP_NOR  = 4'b1100;
    localparam OP_XOR  = 4'b0011;
    localparam OP_SLTU = 4'b0100;
    localparam OP_SLL  = 4'b0101;
    localparam OP_SRL  = 4'b1000;
    localparam OP_SRA  = 4'b1001;

    // Bloco combinacional para decodificação das operações
    always @(*) begin
        case (ALUOp)
            3'b000: OP = OP_ADD;  // Operações de memória (lw, sw) e addi forçam soma
            3'b001: OP = OP_SUB;  // Operações de branch (beq, bne) forçam subtração
            3'b011: OP = OP_AND;  // andi força operação lógica AND
            3'b100: OP = OP_OR;   // ori força operação lógica OR
            3'b101: OP = OP_XOR;  // xori força operação lógica XOR
            3'b110: OP = OP_SLT;  // slti força comparação com sinal
            3'b111: OP = OP_SLTU; // sltiu força comparação sem sinal

            3'b010: begin         // Instruções Tipo-R: avalia o campo func
                case (func)
                    6'b100000: OP = OP_ADD;  // add
                    6'b100010: OP = OP_SUB;  // sub
                    6'b100100: OP = OP_AND;  // and
                    6'b100101: OP = OP_OR;   // or
                    6'b100110: OP = OP_XOR;  // xor
                    6'b100111: OP = OP_NOR;  // nor
                    6'b101010: OP = OP_SLT;  // slt
                    6'b101011: OP = OP_SLTU; // sltu
                    6'b000000: OP = OP_SLL;  // sll
                    6'b000010: OP = OP_SRL;  // srl
                    6'b000011: OP = OP_SRA;  // sra
                    6'b000100: OP = OP_SLL;  // sllv (reutiliza lógica sll)
                    6'b000110: OP = OP_SRL;  // srlv (reutiliza lógica srl)
                    6'b000111: OP = OP_SRA;  // srav (reutiliza lógica sra)
                    default:   OP = OP_ADD;
                endcase
            end
            
            default: OP = OP_ADD;
        endcase
    end

endmodule
