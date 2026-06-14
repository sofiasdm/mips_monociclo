/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: Contador de Programa (PC)
   FUNÇÃO: Armazena e atualiza, a cada pulso de clock, o endereço da 
	instrução que está prestes a ser executada.

   EQUIPE:
   - KAUA GABRIEL DOS SANTOS CELESTINO
   - SOFIA DUARTE DE MENDONCA 
   ==================================================================== */

module pc (
    input wire clock,    // Sinal de clock para atualização síncrona (1 bit) 
    input wire reset,    // Sinal de reset para inicializar o PC em 0x00000000 (1 bit) 
    input wire [31:0] nextPC,   // Próximo valor do PC computado pelo hardware (32 bits) 
    output reg [31:0] PC        // Valor atual armazenado no PC, enviado à memória de instrução (32 bits) [cite: 65, 91]
);

    // Bloco sequencial ativado na borda de subida do clock ou do reset [cite: 63, 65]
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // Se o reset for ativado, o PC volta para o início da memória de instruções (endereço 0)
            PC <= 32'h00000000;
        end else begin
            // Na ausência de reset, o PC recebe o próximo endereço de instrução calculado [cite: 63, 65]
            PC <= nextPC;
        end
    end

endmodule
