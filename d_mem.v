/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: MMemória de Dados (D_MEM)
   FUNÇÃO: Atua como a memória RAM assíncrona para ler ou gravar dados 
   na arquitetura, isolando a saída em alta impedância quando não está a ser lida.
   
   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */

module d_mem #(
    parameter RAM_SIZE = 256 // Tamanho parametrizável da memória de dados
)(
	 input wire clock,            // Entrada de Clock global
    input wire [31:0] Address,   // Endereço de acesso computado pela ULA (32 bits)
    input wire [31:0] WriteData, // Dado fornecido pelo regfile para ser escrito (32 bits)
    input wire MemWrite,         // Sinal de controle que habilita a escrita na RAM (1 bit)
    input wire MemRead,          // Sinal de controle que habilita a leitura na RAM (1 bit)
    output wire [31:0] ReadData  // Dado lido da memória na posição especificada (32 bits)
);

    // Declaração do bloco de memória RAM
    reg [31:0] ram [0:RAM_SIZE-1];

    // Escrita Assíncrona / Combinacional na RAM
    // Em um sistema puramente monociclo assíncrono para RAM, a escrita ocorre direto pelo nível lógico
    always @(*) begin
        if (MemWrite) begin
            ram[Address[31:2]] <= WriteData;
        end
    end
	 
	 // Leitura Assíncrona da RAM controlada pelo sinal de leitura (MemRead)
    // Se MemRead for 1, lê o dado da posição; caso contrário, zera a saída
    assign ReadData = (MemRead == 1'b1) ? ram[Address[31:2]] : 32'h00000000;
	 
	 // Inicialização da RAM com zeros para evitar valores 'x' (indefinidos) na simulação
	 integer i;                                     // Variável de controle do laço
    initial begin                                  // Bloco executado no início da simulação
        for (i = 0; i < RAM_SIZE; i = i + 1) begin // Percorre todas as posições da RAM
            ram[i] = 32'h00000000;                 // Zera a posição para evitar valor lixo ('x')
        end
    end

endmodule
