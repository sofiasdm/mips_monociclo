/* ====================================================================
   DISCIPLINA: Arquitetura e Organização de Computadores
   PROJETO: Implementação de Processador MIPS Monociclo em Verilog
   COMPONENTE: MUX's, sign_extend, shift_left
   FUNÇÃO: 
   mux2x1_32: Seleciona um entre dois caminhos de dados de 32 bits com 
   base num sinal de controle de 1 bit.
   mux2x1_5: Escolhe qual o registrador de destino de 5 bits (rt ou rd) 
   receberá a escrita no banco de registradores.
   mux4x1_32: Alterna entre quatro barramentos de 32 bits, permitindo 
   injetar os dados corretos no banco para instruções como lw, jal e lui.
   sign_extend: Converte os valores imediatos de 16 bits para 32 bits, 
   estendendo o sinal para cálculos aritméticos ou preenchendo com zeros 
   para lógicas.
   shift_left_2: Multiplica o imediato estendido por quatro através de 
   um deslocamento de bits para alinhar os endereços de desvios (branches).

   EQUIPE:
   BERTHO HENRIQUE CORDEIRO DE OLIVEIRA
   KAUÃ GABRIEL DOS SANTOS CELESTINO
   SOFIA DUARTE DE MENDONÇA
   WALLYSON LENILSON LIRA DA SILVA
   ==================================================================== */

/* ====================================================================
   COMPONENTE: Multiplexador 2x1 de 32 bits
   ==================================================================== */

module mux2x1_32 (
    input wire [31:0] In0,   // Entrada 0 (32 bits)
    input wire [31:0] In1,   // Entrada 1 (32 bits)
    input wire        sel,   // Sinal de seleção (1 bit)
    output wire [31:0] Out   // Saída selecionada (32 bits)
);

    // Atribuição contínua usando operador ternário
    assign Out = (sel == 1'b1) ? In1 : In0;

endmodule

/* ====================================================================
   COMPONENTE: Multiplexador 2x1 de 5 bits  
   ==================================================================== */

module mux2x1_5 (
    input wire [4:0] In0,    // Entrada 0 (5 bits - ex: rt)
    input wire [4:0] In1,    // Entrada 1 (5 bits - ex: rd)
    input wire       sel,    // Sinal de seleção (1 bit)
    output wire [4:0] Out    // Saída selecionada (5 bits)
);

    assign Out = (sel == 1'b1) ? In1 : In0;

endmodule

/* ====================================================================
   COMPONENTE: Multiplexador 4x1 de 32 bits
   ==================================================================== */

module mux4x1_32 (
    input wire [31:0] In0,   // Entrada 00
    input wire [31:0] In1,   // Entrada 01
    input wire [31:0] In2,   // Entrada 10
    input wire [31:0] In3,   // Entrada 11
    input wire [1:0]  sel,   // Seletor de 2 bits
    output reg [31:0] Out    // Saída selecionada
);

    always @(*) begin
        case (sel)
            2'b00: Out = In0;
            2'b01: Out = In1;
            2'b10: Out = In2;
            2'b11: Out = In3;
            default: Out = 32'h00000000;
        endcase
    end

endmodule

/* ====================================================================
   COMPONENTE: Extensor de Sinal/Zeros (SIGN_EXTEND)
   ==================================================================== */

module sign_extend (
    input wire [15:0] In,       // Valor imediato de 16 bits
    input wire        Ctrl_Ext, // Controla o tipo: 0 = Sinal, 1 = Zeros
    output reg [31:0] Out       // Saída estendida de 32 bits
);

    always @(*) begin
        if (Ctrl_Ext) begin
            // Extensão com Zeros (Zero-extend)
            Out = {16'h0000, In};
        end else begin
            // Extensão de Sinal (Sign-extend)
            // Duplica o bit In[15] dezasseis vezes à esquerda do número
            Out = {{16{In[15]}}, In};
        end
    end

endmodule

/* ====================================================================
   COMPONENTE: Deslocador de Bits (Shift Left 2)
   ==================================================================== */

module shift_left_2 (
    input wire [31:0] In,  // Entrada de 32 bits
    output wire [31:0] Out // Saída multiplicada por 4
);

    // Faz o shift concatenando os 30 bits menos significativos com dois zeros "2'b00"
    assign Out = {In[29:0], 2'b00};

endmodule
