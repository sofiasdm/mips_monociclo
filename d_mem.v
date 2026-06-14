/* ====================================================================
   ATIVIDADE: Projeto 02 - Implementação de MIPS Monociclo em Verilog
   COMPONENTE: Memória de Dados (D_MEM)
   ==================================================================== */

module d_mem #(
    parameter RAM_SIZE = 256 // Tamanho parametrizável da memória de dados
)(
    input wire [31:0] Address,   // Endereço de acesso computado pela ULA (32 bits)
    input wire [31:0] WriteData, // Dado fornecido pelo regfile para ser escrito (32 bits)
    input wire MemWrite,  // Sinal de controle que habilita a escrita na RAM (1 bit)
    input wire MemRead,   // Sinal de controle que habilita a leitura na RAM (1 bit)
    output wire [31:0] ReadData  // Dado lido da memória na posição especificada (32 bits)
);

    // Declaração do bloco de memória RAM
    reg [31:0] ram [0:RAM_SIZE-1];

    // Escrita Assíncrona / Combinacional na RAM
    // Em um sistema puramente monociclo assíncrono para RAM, a escrita ocorre direto pelo nível lógico
    always @(*) begin
        if (MemWrite) begin
            ram[Address[31:2]] = WriteData;
        end
    end

    // Leitura Assíncrona com lógica de Alta Impedância (Tri-state)
    // Se MemRead for TRUE (1), disponibiliza o dado lido. Se for FALSE (0), fica em alta impedância (Z)
    assign ReadData = (MemRead) ? ram[Address[31:2]] : 32'bz;

endmodule