module PrefixAdder8 (
    input  [7:0] A, B,
    output [7:0] Sum,
    output       Cout
);
    // Señales Generate (G) y Propagate (P)
    wire [7:0] G, P;
    assign G = A & B;  // Generate
    assign P = A ^ B;  // Propagate

    // Wires para el cálculo prefix (3 niveles para 8 bits)
    wire [7:0] G_level [2:0];  // Niveles del árbol prefix
    wire [7:0] P_level [2:0];  

    // --- Inicialización ---
    assign G_level[0] = G;
    assign P_level[0] = P;

    // ========== Árbol Prefix Kogge-Stone ==========
    // Nivel 1: Span 1 (combina bits adyacentes)
    assign G_level[1][0] = G_level[0][0];
    assign P_level[1][0] = P_level[0][0];
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin : level1
            assign G_level[1][i] = G_level[0][i] | (P_level[0][i] & G_level[0][i-1]);
            assign P_level[1][i] = P_level[0][i] & P_level[0][i-1];
        end
    endgenerate

    // Nivel 2: Span 2 (combina cada 2 bits)
    assign G_level[2][0] = G_level[1][0];
    assign P_level[2][0] = P_level[1][0];
    assign G_level[2][1] = G_level[1][1];
    assign P_level[2][1] = P_level[1][1];
    generate
        for (i = 2; i < 8; i = i + 1) begin : level2
            assign G_level[2][i] = G_level[1][i] | (P_level[1][i] & G_level[1][i-2]);
            assign P_level[2][i] = P_level[1][i] & P_level[1][i-2];
        end
    endgenerate

    // Nivel 3: Span 4 (combina cada 4 bits)
    wire [7:0] G_final, P_final;
    assign G_final[0] = G_level[2][0];
    assign P_final[0] = P_level[2][0];
    assign G_final[1] = G_level[2][1];
    assign P_final[1] = P_level[2][1];
    assign G_final[2] = G_level[2][2];
    assign P_final[2] = P_level[2][2];
    assign G_final[3] = G_level[2][3];
    assign P_final[3] = P_level[2][3];
    generate
        for (i = 4; i < 8; i = i + 1) begin : level3
            assign G_final[i] = G_level[2][i] | (P_level[2][i] & G_level[2][i-4]);
            assign P_final[i] = P_level[2][i] & P_level[2][i-4];
        end
    endgenerate

    // --- Cálculo de los carries ---
    wire [8:0] C;
    assign C[0] = 0;  // Carry inicial
    assign C[1] = G_level[0][0];
    assign C[2] = G_level[1][1];
    assign C[3] = G_level[1][2] | (P_level[1][2] & C[1]);
    assign C[4] = G_level[2][3];
    assign C[5] = G_level[2][4] | (P_level[2][4] & C[1]);
    assign C[6] = G_level[2][5] | (P_level[2][5] & C[2]);
    assign C[7] = G_level[2][6] | (P_level[2][6] & C[3]);
    assign C[8] = G_final[7] | (P_final[7] & C[3]);  // Cout

    // --- Suma final ---
    assign Sum = P ^ C[7:0];
    assign Cout = C[8];
endmodule
