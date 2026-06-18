/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: Banco de Testes (Testbench)
   FUNÇÃO: Fornece o sinal de estímulo externo (geração de clock e reset) 
   para poder testar e visualizar as ondas do processador no simulador.

   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */

`timescale 1ns / 1ps

module mips_tb;

    // Sinais de entrada do processador (viram regs no testbench)
    reg clock;
    reg reset;

    // Sinais de saída para monitoramento (viram wires no testbench)
    wire [31:0] out_pc;
    wire [31:0] out_ula;
    wire [31:0] out_dmem;

    // Instancia o processador principal (UUT - Unit Under Test)
    mips_monociclo uut (
        .clock(clock),
        .reset(reset),
        .out_pc(out_pc),
        .out_ula(out_ula),
        .out_dmem(out_dmem)
    );

    // Geração do sinal de Clock (Inverte a cada 10 unidades de tempo -> período de 20ns)
    always begin
        #10 clock = ~clock;
    end

    // Bloco de estímulo inicial
    initial begin
        // Inicializa os sinais
        clock = 0;
        reset = 1;

        // Mantém o reset ativo por 25ns para garantir que o PC e o RegFile limpem
        #25;
        reset = 0;
        
        // Deixa o simulador rodar por tempo suficiente para executar o instruction.list
        #200;
        
        // Encerra a simulação
        $display("Simulação concluída. Verifique as formas de onda.");
        $stop;
    end

endmodule
