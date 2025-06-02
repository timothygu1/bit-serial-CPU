module tt_um_alu_8bit_JorgeArias8644(
                      input [7:0]a,
                      input [15:8]b,
                      input [1:0]PB,
                      output [7:0]led
                      );

    alu_1bit alu_bit0(.at(a[0]),
                      .bt(b[8]),
                      .ALUcontrol(PB),
                      .result(led[0])
                      );
    
    alu_1bit alu_bit1(.at(a[1]),
                      .bt(b[9]),
                      .ALUcontrol(PB),
                      .result(led[1])
                                        
                      );    
    
    alu_1bit alu_bit2(
                        .at(a[2]),
                        .bt(b[10]),
                        .ALUcontrol(PB),
                        .result(led[2])
                                          
                      );    
    
    alu_1bit alu_bit3(
                        .at(a[3]),
                        .bt(b[11]),
                        .ALUcontrol(PB),
                        .result(led[3])
                      );    
    
    alu_1bit alu_bit4(
                        .at(a[4]),
                        .bt(b[12]),
                        .ALUcontrol(PB),
                        .result(led[4])
                      );    
    
    alu_1bit alu_bit5(
                      .at(a[5]),
                      .bt(b[13]),
                      .ALUcontrol(PB),
                      .result(led[5])
                      );    
    
    alu_1bit alu_bit6(
                      .at(a[6]),
                      .bt(b[14]),
                      .ALUcontrol(PB),
                      .result(led[6])
                      );    
    
    alu_1bit alu_bit7(
                       .at(a[7]),
                       .bt(b[15]),
                       .ALUcontrol(PB),
                       .result(led[7])
                       );  
endmodule
