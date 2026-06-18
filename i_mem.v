/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: Memória de Instrução (i_mem)
   FUNÇÃO:Funciona como uma memória ROM assíncrona que lê o arquivo 
   externo e fornece a instrução binária correspondente ao endereço do PC.
   
   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */

module i_mem #(
    parameter MEM_SIZE = 256   // Tamanho parametrizável da memória (quantidade de instruções)
)
(
    input wire [31:0] address, // Endereço de leitura fornecido pelo PC (32 bits)
    output wire [31:0] i_out   // Instrução de 32 bits armazenada na posição correspondente
);

    // Declaração da memória: um vetor de elementos de 32 bits com tamanho MEM_SIZE
    reg [31:0] rom [0:MEM_SIZE-1];

    // Inicialização da memória ROM carregando o arquivo de texto externo em binário
    initial begin
        $readmemb("instruction.list", rom);
    end

    // Leitura assíncrona: mudou o endereço, atualiza a saída imediatamente.
    // Divisão por 4 (address[31:2]) necessária porque o PC pula de 4 em 4 bytes.
    assign i_out = rom[address[31:2]];

endmodule
