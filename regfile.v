/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: Banco de Registradores (REGFILE)
   FUNÇÃO: Gerencia os 32 registradores internos do MIPS, permitindo 
   ler dois valores de forma assíncrona e gravar um resultado sronicamente.

   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */

module regfile (
    input wire Clock,      // Sinal de clock para sincronizar as escritas (1 bit)
    input wire Reset,      // Reseta todos os 32 registradores para zero (1 bit)
    input wire [4:0]  ReadAddr1,  // Endereço do primeiro registrador a ser lido (5 bits)
    input wire [4:0]  ReadAddr2,  // Endereço do segundo registrador a ser lido (5 bits)
    input wire [4:0]  WriteAddr,  // Endereço do registrador onde será feito a escrita (5 bits)
    input wire [31:0] WriteData,  // Dado de 32 bits a ser escrito
    input wire        RegWrite,   // Habilita escrita quando em nível lógico alto (1 bit)
    output wire [31:0] ReadData1, // Conteúdo lido assincronamente do endereço ReadAddr1
    output wire [31:0] ReadData2  // Conteúdo lido assincronamente do endereço ReadAddr2
);

    // Declaração dos 32 registradores de 32 bits cada
    reg [31:0] registers [0:31];
    integer i;

    // Escrita Síncrona e Lógica de Reset
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            // Sobrescreve todos os 32 registradores com zero absoluto ao resetar
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h00000000;
            end
        end else if (RegWrite && (WriteAddr != 5'b00000)) begin
            // Realiza a escrita apenas se RegWrite for 1 e o destino NÃO for o registrador $0
            registers[WriteAddr] <= WriteData;
        end
    end

    // Leituras Assíncronas (Sem dependência de clock)
    // Se o endereço pedido for o registrador 0, retorna 0 fixo. Caso contrário, lê o banco.
    assign ReadData1 = (ReadAddr1 == 5'b00000) ? 32'h00000000 : registers[ReadAddr1];
    assign ReadData2 = (ReadAddr2 == 5'b00000) ? 32'h00000000 : registers[ReadAddr2];

endmodule
