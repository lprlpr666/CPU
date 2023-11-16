module MemCtrl (
    input wire clk,
    input wire rst,
    input wire rdy,

    input  wire [ 7:0] mem_din,   // data input bus
    output reg  [ 7:0] mem_dout,  // data output bus
    output reg  [31:0] mem_a,     // address bus (only 17:0 is used)
    output reg         mem_wr,    // write/read signal (1 for write)

    input wire io_buffer_full,  // 1 if uart buffer is full

    // instruction fetch
    input  wire        if_en,
    input  wire [31:0] if_pc,
    output reg         if_done,
    output reg  [31:0] if_data
    //if_en（输入信号）：

// 类型：单比特的输入线（input wire）。
// 作用：这是一个使能信号，用于控制指令获取的操作。当此信号为高（1）时，启动指令获取过程。
// if_pc（输入信号）：

// 类型：32位宽的输入线（input wire [31:0]）。
// 作用：这个信号代表程序计数器（Program Counter）的值，指明当前需要获取指令的内存地址。它指示模块从哪个地址开始读取指令。
// if_done（输出信号）：

// 类型：单比特的输出寄存器（output reg）。
// 作用：这个信号表明指令获取过程是否已经完成。通常在指令读取完成后，此信号会被设置为高（1）。
// if_data（输出信号）：

// 类型：32位宽的输出寄存器（output reg [31:0]）。
// 作用：这个信号用于输出读取的指令数据。当一个指令被完全读取后，它的内容会被放置在这个寄存器中。
);

  localparam IDLE = 0, IF = 1, LOAD = 2, STORE = 3;
  //IDLE（空闲）、IF（指令获取）、LOAD（加载）、STORE（存储）
  reg [1:0] status;
  reg [2:0] stage;

  always @(posedge clk) begin
    if (rst) begin
      status  <= IDLE;
      if_done <= 0;
      mem_wr  <= 0;
      mem_a   <= 0;
    end else if (!rdy) begin
      if_done <= 0;
      mem_wr  <= 0;
      mem_a   <= 0;
    end else begin

       
      if (status == IF) begin //准备好了
        case (stage)
          3'h1: if_data[7:0] <= mem_din;
          3'h2: if_data[15:8] <= mem_din;
          3'h3: if_data[23:16] <= mem_din;
          3'h4: if_data[31:24] <= mem_din;
        endcase
        if (stage == 3'h4) begin
          stage  <= 3'h0;
          status <= IDLE;
          mem_wr <= 0;
          mem_a  <= 0;
        end else begin
          mem_a <= mem_a + 1;
          stage <= stage + 1;
        end
      end else if (if_en) begin
        mem_wr  <= 0;
        mem_a   <= if_pc;
        stage   <= 3'h1;
        if_done <= 0;
      end
    end
  end

endmodule