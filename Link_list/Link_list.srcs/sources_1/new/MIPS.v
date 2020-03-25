`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/12 08:48:37
// Design Name: 
// Module Name: MIPS
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top #(parameter WIDTH =32 )(seg7, scan, clk, SW, btn, led);
    input clk;
    input [4:0]btn;
    input [15 : 0] SW;
    output [7:0] seg7;
    output [3:0] scan;
    output [15 : 0] led;

    reg clk1=0;	
    reg reset,reset1;
    wire memread,memwrite;
    wire [WIDTH-1:0] adr,writedata;
    wire [WIDTH-1:0] memdata;
    wire [WIDTH-1:0] rd3;
    wire [WIDTH - 1 : 0] rd4;
    wire [3 : 0] scan;
    wire [7 : 0] seg7; 
    wire [15 : 0] led;
    wire [WIDTH - 1 : 0] random_digit;
    reg count1=0;

    
    always @ (posedge clk) begin 
        if(count1 == 1)
            begin clk1<=~clk1;
            count1<=0;end
        else
            begin count1<=count1+1;end
    end
    
  
    mips #(WIDTH) dut(clk1,reset,memdata,memread,memwrite,adr,writedata,rd3, rd4, SW, btn, random_digit);
    display a(clk1,rd3, rd4, seg7,scan, led, random_digit);
    exmemory #(WIDTH) exmem(clk1,reset,memwrite,adr,writedata,memdata);
    //initial
    initial begin
        reset<=0;
        clk1<=0;
    end
endmodule


module display(clk, rd3, rd4, seg7, scan, led, random_digit);
    input clk;
    input [31:0]rd3;
    input [31 : 0] rd4;
    input [31 : 0] random_digit;
    output seg7;
    output scan;
    output [15 : 0] led;
    reg[4:0] data=0;
    //reg[4:0] data1=0;
    reg [3:0] scan;
    reg [7:0] seg7;
    reg [2:0] cnt=2'b00;
    reg [15 : 0] led;
    reg clk1khz=0;
    reg [20:0] count1=0;
    reg [1 : 0] cnt2 = 0;
    reg[31:0] num;

//分频
  always @ (posedge clk) begin 
      if(count1 == 25000) begin 
          clk1khz<=~clk1khz;
          count1<=0;
      end
      else begin 
          count1<=count1+1;
      end
  end
  
//将1khz时钟信号四分 -赋给cnt
always @(posedge clk1khz)
begin
    if(rd3==32'b00000000000000001111111111111111) cnt[2]=1;
	if(cnt[0]==1 && cnt[1]==1)
		  begin
		  if(rd3==32'b00000000000000001111111111111111)  begin cnt=3'b100; end
		  else  cnt=0;
		  end
	   else
		begin cnt<=cnt+1;end

end



always @(*)
      begin
         case(cnt)        //t1赋给data    
         3'b000:begin data[3:0]<=rd3[3:0];led[15:0]<=rd3[15:0]; data[4]<=0;scan[3:0]<=4'b1110/*&{4{blink[0]}}*/;end    //个位数值
         3'b001:begin data[3:0]<=rd3[7:4];led[15:0]<=rd3[15:0];data[4]<=0;scan[3:0]<=4'b1101/*&{4{blink[0]}}*/;end    //十位
         3'b010:begin data[3:0]<=rd3[11:8];led[15:0]<=rd3[15:0];data[4]<=0;scan[3:0]<=4'b1011/*&{4{blink[1]}}*/;end   //百位
         3'b011:begin data[3:0]<=rd3[15:12];led[15:0]<=rd3[15:0];data[4]<=0;scan[3:0]<=4'b0111/*&{4{blink[1]}}*/;end  //千位
         3'b100:begin data[4:0]<=5'b10000;
                      led[15:0]<=rd3[15:0];
                      scan[3:0]<=4'b1110;end
         3'b101:begin data[4:0]<=5'b10001;
                               led[15:0]<=rd3[15:0];

                      scan[3:0]<=4'b1101/*&{4{blink[0]}}*/;end    //十位   
         3'b110:begin data[4:0]<=5'b10010;
                               led[15:0]<=rd3[15:0];

                      scan[3:0]<=4'b1011/*&{4{blink[1]}}*/;end   //百位
         3'b111:begin data[4:0]<=5'b10011;
                               led[15:0]<=rd3[15:0];
                      scan[3:0]<=4'b0111/*&{4{blink[1]}}*/;end  //千位                                                 
         default:begin data<=5'b1;                       led[15:0]<=rd3[15:0];
scan<=4'b1111;end
   endcase
end
always @ (*)
begin                        
if(data[4])		
 case(data[4:0])
   5'b10011:seg7[7:0]=8'b10100001;//d
   5'b10010:seg7[7:0]=8'b11000000;//0和o
   5'b10001:seg7[7:0]=8'b11001000;//n
   5'b10000:seg7[7:0]=8'b10000110;//e
   default:seg7[7:0]=8'b10001110;//11111111;:
   endcase
//数值对应七段数码管显示灯
else
	case(data[3:0])
	4'b0000:seg7[7:0]=8'b11000000;//0和o
	4'b0001:seg7[7:0]=8'b11111001;//1
	4'b0010:seg7[7:0]=8'b10100100;//2
	4'b0011:seg7[7:0]=8'b10110000;//3
	4'b0100:seg7[7:0]=8'b10011001;//4
	4'b0101:seg7[7:0]=8'b10010010;//5
	4'b0110:seg7[7:0]=8'b10000010;//6
	4'b0111:seg7[7:0]=8'b11111000;//7
	4'b1000:seg7[7:0]=8'b10000000;//8
	4'b1001:seg7[7:0]=8'b10010000;//9
	4'b1010:seg7[7:0]=8'b10001000;//a
    4'b1011:seg7[7:0]=8'b10000011;//b
    4'b1100:seg7[7:0]=8'b11000110;//c
    4'b1101:seg7[7:0]=8'b10100001;//d
    4'b1110:seg7[7:0]=8'b10000110;//e
    4'b1111:seg7[7:0]=8'b10001110;//f

//	4'b0000:seg7[7:0]=8'b11001000;//n
//1101000010101110
	default:seg7[7:0]=8'b11111111;//11111111;
	endcase
end
endmodule




//external memory
module exmemory #(parameter WIDTH =32)
    (clk,reset,memwrite,adr,writedata,memdata);
    input clk;
    input reset;
    input memwrite;
    input [WIDTH-1:0] adr,writedata;
    output reg [WIDTH-1:0] memdata;
    reg [31:0] RAM [2047:0];//8KB
    wire [31:0] word;
    initial begin
        $readmemh("C:/Users/lenovo/Desktop/test.dat",RAM);
       
    end
    always @(posedge clk) begin
        if(memwrite) begin
            RAM[adr] <= writedata;    
        end
    end
    assign word =RAM[adr];
    always @(*) begin
        memdata <=word;
    end
endmodule


//mips
module mips #(parameter WIDTH=32) 
    (input clk,reset,
    input [WIDTH-1:0] memdata,
    output memread,memwrite,
    output [WIDTH-1:0] adr,writedata,rd3, rd4,
    input [15  : 0] SW,
    input [4:0]btn,
    output [WIDTH - 1 : 0] random_digit
    );
    wire [31:0] instr;//IR
    wire memtoreg,irwrite,iord,pcen,regwrite,regdst,zero;
    wire [1:0] alusrca,alusrcb,pcsource;
    wire [5:0] aluop;
    //CU
    controller cont(clk,reset,instr[31:26],instr[5:0],
        zero,memread,memwrite,memtoreg,iord,irwrite,
        pcen,regwrite,regdst,pcsource,alusrca,alusrcb,
        aluop);
    //datapath
    datapath #(WIDTH) dp(clk,reset,memdata,memtoreg,iord,pcen,regwrite,regdst,
    irwrite,alusrca,alusrcb,pcsource,aluop,zero,
    instr,adr,writedata,rd3, rd4, SW, btn, random_digit);
  
endmodule

//CU
module controller(input clk,reset, 
                  input [5:0] op,
                  input [5:0] func,
                  input zero,
                  output reg memread,memwrite,memtoreg,iord,irwrite,
                  output pcen,
                  output reg regwrite,regdst,
                  output reg [1:0] pcsource,alusrca,alusrcb,
                  output reg[5:0] aluop);
    //state
    parameter FETCHS =4'b0000;
    parameter DECODES=4'b0001;
    parameter MTYPES =4'b0010;
    parameter ITYPES =4'b0011;
    parameter JRUMPS =4'b0100;
    parameter BEQS =4'b0101;
    parameter BLTZS =4'b0110;
    parameter BGTZS =4'b0111;
    parameter JUMPS =4'b1000;
    parameter ReadMS =4'b1001;
    parameter WriteMS=4'b1010;
    parameter IWriteToRegS=4'b1011;
    parameter RITYPES=4'b1100;
    parameter ROTYPES=4'b1101;
    parameter MWriteToRegS=4'b1110;
    parameter RWriteToRegS=4'b1111;
    //OP[5:0]
    parameter RType =6'b000000;
    parameter Bltzop =6'b000001;
    parameter Jop =6'b000010;
    parameter Beqop =6'b000100;
    parameter Bgtzop =6'b000111;
    parameter Addiop =6'b001000;
    parameter Addiuop =6'b001001;
    parameter Sltiop =6'b001010;
    parameter Andiop =6'b001100;
    parameter Oriop =6'b001101;
    parameter Xoriop =6'b001110;
    parameter Luiop =6'b001111;
    parameter Lwop =6'b100011;
    parameter Swop =6'b101011;
    //func
    parameter Func1 =6'b000000;
    parameter Func2 =6'b000010;
    parameter Func3 =6'b000011;
    parameter Func4 =6'b000100;
    parameter Func5 =6'b000111;
    parameter Func6 =6'b001000;
    parameter Func7 =6'b100000;
    parameter Func8 =6'b100001;
    parameter Func9 =6'b100010;
    parameter Func10 =6'b100011;
    parameter Func11 =6'b100110;
    parameter Func12 =6'b100100;
    parameter Func13 =6'b100101;
    parameter Func14 =6'b100111;
    parameter Func15 =6'b101010;
    reg [3:0] state,nextstate;
    reg pcwrite,pcwritecond;
    always @(posedge clk ) begin
        if(reset) begin
            state <=FETCHS;
        end 
        //  state <=FETCHS;
        else begin
            state <=nextstate;
        end
    end
    always @(*) begin
        case(state)
            FETCHS : nextstate <=DECODES;
            DECODES: begin
                case(op)
                    RType: begin
                        case(func)
                            Func1: nextstate<=RITYPES;
                            Func2: nextstate<=RITYPES;
                            Func3: nextstate<=RITYPES;
                            Func4: nextstate<=ROTYPES;
                            Func5: nextstate<=ROTYPES;
                            Func6: nextstate<=JRUMPS;
                            Func7: nextstate<=ROTYPES;
                            Func8: nextstate<=ROTYPES;
                            Func9: nextstate<=ROTYPES;
                            Func10: nextstate<=ROTYPES;
                            Func11: nextstate<=ROTYPES;
                            Func12: nextstate<=ROTYPES;
                            Func13: nextstate<=ROTYPES;
                            Func14: nextstate<=ROTYPES;
                            Func15: nextstate<=ROTYPES;
                        endcase
                    end
                        
                    Bltzop: nextstate <=BLTZS;
                    Jop: nextstate <=JUMPS;
                    Beqop: nextstate<=BEQS;
                    Bgtzop: nextstate<=BGTZS;
                    Addiop: nextstate<=ITYPES;
                    Addiuop: nextstate<=ITYPES;
                    Sltiop: nextstate<=ITYPES;
                    Andiop: nextstate<=ITYPES;
                    Oriop: nextstate<=ITYPES;
                    Xoriop: nextstate<=ITYPES;
                    Luiop: nextstate<=ITYPES;
                    Lwop: nextstate<=MTYPES;
                    Swop: nextstate<=MTYPES;
                    default:nextstate<=FETCHS;
                endcase
            end
            ITYPES: nextstate<=IWriteToRegS;
            RITYPES: nextstate<=RWriteToRegS;
            ROTYPES: nextstate<=RWriteToRegS;
            BLTZS: nextstate<=FETCHS;
            BEQS: nextstate<=FETCHS;
            BGTZS: nextstate<=FETCHS;
            JUMPS: nextstate<=FETCHS;
            JRUMPS: nextstate<=FETCHS;
            MTYPES: begin
                case(op)
                    Lwop: nextstate<=ReadMS;
                    Swop: nextstate<=WriteMS;
                endcase
            end
            ReadMS: nextstate<=MWriteToRegS;
            WriteMS: nextstate<=FETCHS;
            IWriteToRegS: nextstate<=FETCHS;
            MWriteToRegS: nextstate<=FETCHS;
            RWriteToRegS: nextstate<=FETCHS;
            default: nextstate<=FETCHS;
        endcase
    end
    always @(*) begin
        irwrite <= 0;
        pcwrite <= 0; 
        pcwritecond <= 0;
        regwrite <= 0; 
        regdst <= 0;
        memread <= 0; 
        memwrite <= 0;
        alusrca <= 2'b00; 
        alusrcb <= 2'b00; 
        aluop <= 6'b100000;
        pcsource <= 2'b00;
        iord <= 0; 
        memtoreg <= 0;
        case(state)
            FETCHS: begin
                iord<=0;
                irwrite<=1;
                memread<=1;
                memwrite<=0;
                alusrca<=2'b00;
                alusrcb<=2'b01;
                pcsource<=2'b00;
                pcwrite<=1;
                aluop<=6'b100000;
            end
            DECODES: begin
                aluop<=6'b100000;
                alusrca<=2'b00;
                alusrcb<=2'b11;
            end
            MTYPES: begin
                alusrca<=2'b01;
                alusrcb<=2'b11;
                aluop<=6'b100000;
            end
            ITYPES: begin
                alusrca<=2'b01;
                alusrcb<=2'b11;
                case(op)
                    Addiop: aluop<=6'b100000;
                    Addiuop: aluop<=6'b100001;
                    Sltiop: aluop<=6'b101010;
                    Andiop: aluop<=6'b100100;
                    Oriop: aluop<=6'b100101;
                    Xoriop: aluop<=6'b100110;
                    Luiop: aluop<=6'b010001;
                endcase
            end
            JRUMPS: begin
                pcwrite<=1;
                pcsource<=2'b11;
            end
            BEQS: begin
                alusrca<=2'b01;
                alusrcb<=2'b00;
                aluop<=6'b100010;
                pcsource<=2'b01;
                pcwritecond<=1;
            end
            BLTZS: begin
                alusrca<=2'b01;
                alusrcb<=2'b00;
                aluop<=6'b000001;
                pcsource<=2'b01;
                pcwritecond<=1;
                pcwrite<=0;
            end
            BGTZS: begin
                alusrca<=2'b01;
                alusrcb<=2'b00;
                aluop<=6'b001010;
                pcsource<=2'b01;
                pcwritecond<=1;
                pcwrite<=0;
            end
            JUMPS: begin
                pcwrite<=1;
                pcsource<=2'b10;
            end
            ReadMS: begin
                memread<=1;
                iord<=1;
            end
            WriteMS: begin
                memwrite<=1;
                iord<=1;
            end
            IWriteToRegS: begin
                memtoreg<=0;
                regwrite<=1;
                regdst<=0;
            end
            RITYPES: begin
                alusrca<=2'b10;
                alusrcb<=2'b00;
                case(func)
                    Func1: aluop<=6'b000000;
                    Func2: aluop<=6'b000010;
                    Func3: aluop<=6'b000011;
                endcase
            end
            ROTYPES: begin
                alusrca<=2'b01;
                alusrcb<=2'b00;
                case(func)
                    Func4: aluop<=6'b000000;
                    Func5: aluop<=6'b000010;
                    Func7: aluop<=6'b100000;
                    Func8: aluop<=6'b100001;
                    Func9: aluop<=6'b100010;
                    Func10:aluop<=6'b100011;
                    Func11:aluop<=6'b100110;
                    Func12:aluop<=6'b100100;//and
                    Func13:aluop<=6'b100101;
                    Func14:aluop<=6'b100111;
                    Func15:aluop<=6'b101010;
                endcase
            end
            MWriteToRegS: begin
                regdst<=0;
                regwrite<=1;
                memtoreg<=1;
            end
            RWriteToRegS: begin
                regdst<=1;
                regwrite<=1;
                memtoreg<=0;
            end
        endcase
    end
    assign pcen =pcwrite|(pcwritecond & zero);
endmodule


//datapath
module datapath #(parameter WIDTH =32 )
        (input clk,reset,
         input [WIDTH-1:0] memdata,
         input memtoreg,iord,pcen,regwrite,regdst,irwrite,
         input [1:0] alusrca,alusrcb,pcsource,
         input [5:0] aluop,
         output zero,
         output [31:0] instr,
         output [WIDTH-1:0] adr,writedata,rd3, rd4,
         input [15 : 0] SW,
         input [4:0]btn,
         output [WIDTH - 1 : 0] random_digit);
    parameter CONST_ZERO = 32'b0;
    parameter CONST_ONE = 32'b1;
    wire [4:0] ra1,ra2,wa;
    wire [WIDTH-1:0] pc,nextpc,md,rd1,rd2,rd5,rd6,rd7,wd,a,src1,src2,aluresult,aluout;
    wire [31:0] jp1;
    assign jp1 ={6'b000000,instr[25:0]};
    wire [31:0] ta1,ta2;
    assign ta1 ={27'b0,instr[10:6]};
    assign ta2 ={16'b0,instr[15:0]};
    assign ra1 =instr[25:21];
    assign ra2 =instr[20:16];
    mux2 regmux(instr[20:16],instr[15:11],regdst,wa);
    flopen #(32) ir(clk,irwrite,memdata,instr);
    //datapath
    flopenr #(WIDTH) pcreg(clk,reset,pcen,nextpc,pc);
    flop #(WIDTH) mdr(clk,memdata,md);
    flop #(WIDTH) areg(clk,rd1,a);
    flop #(WIDTH) wrd(clk,rd2,writedata);
    flop #(WIDTH) res(clk,aluresult,aluout);
    mux2 #(WIDTH) adrmux(pc,aluout,iord,adr);
    mux4 #(WIDTH) src1mux(pc,a,ta1,ta2,alusrca,src1);
    mux4 #(WIDTH) src2mux(writedata,CONST_ONE,ta1,ta2,alusrcb,src2);
    mux4 #(WIDTH) pcmux(aluresult,aluout,jp1,rd1,pcsource,nextpc);
    mux2 #(WIDTH) wdmux(aluout,md,memtoreg,wd);
    regfile #(WIDTH) rf(clk,reset,regwrite,ra1,ra2,wa,wd,rd1,rd2,rd3, rd4,rd5,rd6,rd7, SW, btn, random_digit);
    alu #(WIDTH) alunit(src1,src2,aluop,aluresult);
    zerodetect #(WIDTH) zd(aluresult,zero);
endmodule


//ALU 
module alu #(parameter WIDTH=32)
      (
      input [WIDTH-1:0] a,b,
       input [5:0] aluop,
       output reg [WIDTH-1:0] result
       );
    wire [30:0] b2;
    assign b2=a[30:0];
    wire [WIDTH-1:0] sum,slt,shamt;
    always @(*) begin
        case(aluop)
            6'b000000: result<=(b<<a);
            6'b000010: result<=(b>>a);
            6'b000011: result<=(b>>>a);
            6'b001000: result<= 32'b0;
            6'b100000: result<=(a+b);
            6'b100001: result<=(a+b);
            6'b100010: result<=(a-b);
            6'b100011: result<=(a-b);
            6'b100110: result<=(a^b);
            6'b100100: result<=(a&b);
            6'b100101: result<=(a|b);
            6'b100111: result<=~(a&b);
            6'b101010: result<=(a<b? 1:0);
            6'b000001: result<=(a<0 ? 0:1); //Bltz
            6'b001010: result<=(a>0 ? 0:1); //Bgtz     
            6'b010001: result<=((b<<16)& 32'b11111111111111110000000000000000);//LUI
        endcase
    end
endmodule



//regfile  -寄存器 rd-register data
//module regfile #(parameter WIDTH=32,REGBITS=5)
//      (input clk,
//      input reset,
//      input regwrite,
//      input [REGBITS-1:0] ra1,ra2,wa,
//      input [WIDTH-1:0] wd,
//      output [WIDTH-1:0] rd1,rd2,rd3,rd4,rd5,rd6,rd7,
//            input [15:0]SW,
//            input [4:0]btn);
//  reg [WIDTH-1:0] RAM2 [(1<<REGBITS)-1:0];  //[31:0] 寄存器RAM2
//    initial
//    begin
//    end

////分配rd1-rd7    
//  assign rd1 =ra1 ? RAM2[ra1]:0;  //由指令的[25:21]为决定数据rd1
//  assign rd2 =ra2 ? RAM2[ra2]:0;  //由指令的[20:16]为决定数据rd2
  
//  assign rd3 =RAM2[20];			  //rd3由内存中的一个字决定    只要将内存改写就可以用display显示
  
//  assign rd4 =RAM2[22];        //按键
//  assign rd5=RAM2[21];         //识别done
//  assign rd6=RAM2[28];       //按键比较值
//  assign rd7=RAM2[15];
      
// //RAM[8]存储当前按键
//  always @(posedge clk)  //每个时钟状态出发    将当前5个按键的状态存入ram[8]  拨码的状态存入ram[13][12]
//  begin
//  if(btn[1]==1) RAM2[22]=8;          //右键
//  else if(btn[0]==1)    RAM2[22]=16; //左键
//  else if(btn[2]==1)   RAM2[22]=4;   //上键
//  else if(btn[3]==1)    RAM2[22]=2;  //下键
//  else if(btn[4]==1)  RAM2[22]=1;  //中心键
//  else  RAM2[22]=0;
  
//  //RAM2[8]=btn[4:0];
//  //RAM2[13]=SW[7:0];
//  RAM2[12]=SW[15:0];       //增加的代码
  
//  if(regwrite)            //寄存器写
//    RAM2[wa]<=wd;
//    end
//endmodule


//regfile
module regfile #(parameter WIDTH=32,REGBITS=5)
    (input clk,
    input reset,
    input regwrite,
    input [REGBITS-1:0] ra1,ra2,wa,
    input [WIDTH-1:0] wd,
    output [WIDTH-1:0] rd1,rd2,rd3, rd4,rd5,rd6,rd7,
    input [15 : 0] SW,
    input [4:0]btn,
    output [WIDTH - 1 : 0] random_digit);
    reg [WIDTH-1:0] RAM2 [(1<<REGBITS)-1:0];
    
    
    
//    reg clk2 = 0;

//    reg [32 : 0] counter = 0;

//    reg [4 : 0] btn_check = 0;

//    always @(posedge clk) begin
//        if (counter == 2000000) begin
//            counter <= 0;
//            clk2 <= ~clk2;
//        end 
//        else begin
//            counter <= counter + 1;
//        end

//        if(regwrite) begin
//            RAM2[wa]<=wd;  
//        end 

//        if (RAM2[16] == 32669) begin
//            RAM2[12] <= 0;
//        end

//        if (RAM2[12] == 0) begin 
//            case (SW) 
//                16'b0000000000000001: RAM2[12] <= 1;
//                16'b0000000000000010: RAM2[12] <= 2;
//                16'b0000000000000100: RAM2[12] <= 4;
//                default: RAM2[12] = 0;
//            endcase
//        end

//        if (counter == 1999999) begin
//            case(btn) 
//                5'b00001: RAM2[8] <= 16;
//                5'b00010: RAM2[8] <= 8;
//                5'b00100: RAM2[8] <= 4;
//                5'b01000: RAM2[8] <= 2;
//                5'b10000: begin
//                    RAM2[8] <= 1;
//                    RAM2[12] <= 0;
//                end
//                5'b00000: RAM2[8] <= 0;
//                default: RAM2[8] <= 0;
//            endcase
//        end
//    end

//    always @(posedge clk2) begin
//        btn_check <= btn;
//    end
    
    
//    assign rd1 = ra1 ? RAM2[ra1]:0;
//    assign rd2 = ra2 ? RAM2[ra2]:0;
//    assign rd3 = RAM2[16];
//    assign rd4 = RAM2[23];
//    assign random_digit = RAM2[14];
    
    
     //RAM[8]存储当前按键
 always @(posedge clk)  //每个时钟状态出发    将当前5个按键的状态存入ram[8]  拨码的状态存入ram[13][12]
 begin
 if(btn[1]==1) RAM2[22]=8;          //右键
 else if(btn[0]==1)    RAM2[22]=16; //左键
 else if(btn[2]==1)   RAM2[22]=4;   //上键
 else if(btn[3]==1)    RAM2[22]=2;  //下键
 else if(btn[4]==1)  RAM2[22]=1;  //中心键
 else  RAM2[22]=0;
 
 //RAM2[8]=btn[4:0];
 //RAM2[13]=SW[7:0];
 RAM2[12]=SW[15:0];       //增加的代码
 
 if(regwrite)            //寄存器写
   RAM2[wa]<=wd;
   end
    
    //分配rd1-rd7    
      assign rd1 =ra1 ? RAM2[ra1]:0;  //由指令的[25:21]为决定数据rd1
      assign rd2 =ra2 ? RAM2[ra2]:0;  //由指令的[20:16]为决定数据rd2
      assign rd3 =RAM2[20];              //rd3由内存中的一个字决定    只要将内存改写就可以用display显示      
      assign rd4 =RAM2[22];        //按键
      assign rd5=RAM2[21];         //识别done
      assign rd6=RAM2[28];       //按键比较值
      assign rd7=RAM2[15];
      
endmodule






//zerodetect  
module zerodetect #(parameter WIDTH=32)
    (input [WIDTH-1:0] a,
    output y);
    assign y= (a == 0);
endmodule
//flop 
module flop #(parameter WIDTH =32)
    (input clk,
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);
    always @(posedge clk) begin
        q<=d;
    end
  
endmodule
//flopen
module flopen #(parameter WIDTH =32)
   (input clk,en,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q);
    always @(posedge clk) begin
        if(en) begin
            q<=d;
        end
    end
  
endmodule
//flopenr
module flopenr #(parameter WIDTH =32)
    (input clk,reset,en,
     input [WIDTH-1:0] d,
     output reg [WIDTH-1:0] q);
    always @(posedge clk) begin
        if(reset) begin
            q<=0;
        end
        else begin
            if(en) begin
                q<=d;
            end
        end
    end
  
endmodule
//mux2
module mux2 #(parameter WIDTH =32)
    (input [WIDTH-1:0] d0,d1,
     input s,
     output [WIDTH-1:0] y);
    assign y= s ? d1:d0;
endmodule
//mux4
module mux4 #(parameter WIDTH =32)
    (input [WIDTH-1:0] d0,d1,d2,d3,
     input [1:0] s,
     output reg [WIDTH-1:0] y);
     always @(*) begin
        case(s)
            2'b00: y<= d0;
            2'b01: y<= d1;
            2'b10: y<= d2;
            2'b11: y<= d3;
        endcase
     end
endmodule


