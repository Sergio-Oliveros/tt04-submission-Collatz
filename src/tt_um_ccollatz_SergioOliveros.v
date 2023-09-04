`timescale 1ns / 1ps


module tt_um_ccollatz_SergioOliveros(
    input clk, //Clock
    input ena, //Start
    input rst_n, //Reset
    input [7:0] uio_in,
    input [7:0] ui_in, //Numero de entrada - N
    output wire [7:0] uio_out, //Contador de iteraciones - c
    output wire [7:0] uo_out, //Busy - busy
    output wire [7:0] uio_oe 
    //output reg [7:0] n
    );
   
    assign uio_oe = 8'b11111111;
    
    parameter inicio = 2'b00;
    parameter par = 2'b01;
    parameter impar = 2'b11;
    
    wire start;
    reg busy;
    assign uo_out = {{7{1'b0}}, busy};
    assign start = ena;
     
    wire [7:0] rca, eca, rna;
    reg [7:0] n;
    reg ec,rc;
    reg [1:0] rn;
    reg [1:0] presente = inicio;
    reg [1:0] futuro;
    reg [7:0] uio_outr;
    assign uio_out = uio_outr;
    ////////////////Datapath 1//////////////////
    always@(posedge clk) begin
        uio_outr <= rca;               
    end 
   
    assign eca = (ec)?(16'b1+uio_outr):uio_outr;
    assign rca = (rc)?16'b0:eca;
    ////////////////Datapath 2//////////////////
    always@(posedge clk) begin
        n <= rna;               
    end 
    
    always@(posedge clk)
        case (rn)
            2'b00: n <= n;
            2'b01: n <= n/16'd2;
            2'b10: n <= ((16'd3)*n)+(16'd1);
            default: n <= ui_in;
        endcase 
           ////////////////Máquina de estados//////////////////
    ////////////////Registro de estados//////////////////
    always@(posedge clk)
        presente <= futuro;
    ////////////////Lógica del estado siguiente//////////////////
    always@(*) begin
        case(presente)
            inicio:
                if(start)
                    if(ui_in[0] <= 1'b0)
                        futuro <= par;
                    else 
                        futuro <= impar;
                else 
                    futuro <= inicio;
                    
            par:
                if (n!=16'd2 && n[1] == 1'b0)
                    futuro <= par;
                else if (n!=16'd2 && n[1] != 1'b0) 
                    futuro <= impar;
                else 
                    futuro <= inicio;
                    
            impar:
                futuro <= par;              
                
            default:
                futuro <= inicio;
        endcase
    end
    ////////////////Lógica de salida//////////////////
    always@(*)
        case(presente)  
        inicio: {ec,rc,rn[1],rn[0],busy} = 5'b01110;
        par: {ec,rc,rn[1],rn[0],busy} = 5'b10011;
        impar: {ec,rc,rn[1],rn[0],busy} = 5'b10101;
        default: {ec,rc,rn[1],rn[0],busy} = 5'b00000;
    endcase
endmodule
    

