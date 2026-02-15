module Data_Memory #(
    parameter int DEPTH_WORDS = 1024
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] addr,
    input  logic [31:0] dataW,
    input  logic        MemRW,
    input  logic [1:0]  MemSize,
    input  logic        MemUnsigned,
    output logic [31:0] dataR

    // Thêm I/O
    //input  logic [7:0]  sw,         // switch ngoài board
    //output logic [7:0]  led         // led ngoài board
);
    // RAM
    logic [7:0] mem [DEPTH_WORDS-1:0];

    // Thanh ghi hold LED
    logic [7:0] led_reg;
    assign led = led_reg;

    // Địa chỉ I/O
    //localparam logic [31:0] SW_ADDR  = 32'h0001_0000;
    //localparam logic [31:0] LED_ADDR = 32'h0001_0004;

    // ---------------- WRITE (sync) ----------------
    always_ff @(posedge clk) begin
        //if (!rst_n) begin
        //    led_reg <= 8'b0;
        //end else begin
        //    // Ghi LED
        //    if (MemRW && (addr == LED_ADDR)) begin
        //        led_reg <= dataW[7:0];
        //    end

        //    // Ghi RAM bình thường
        //    if (MemRW && (addr[1:0] == 2'b00) &&
        //        (addr[31:2] < DEPTH_WORDS) &&
        //        (addr != LED_ADDR)) begin
        //        mem[addr[31:2]] <= dataW;
        //    end
        //end
        unique case(MemSize)
            2'b00: begin // byte
                if (MemRW && (addr < DEPTH_WORDS)) begin
                    mem[addr] <= dataW[7:0];
                end
            end
            2'b01: begin // half-word
                if (MemRW && (addr+1 < DEPTH_WORDS)) begin
                    mem[addr]   <= dataW[7:0];
                    mem[addr+1] <= dataW[15:8];
                end
            end
            2'b10: begin // word
                if (MemRW && (addr+3 < DEPTH_WORDS)) begin
                    mem[addr]   <= dataW[7:0];
                    mem[addr+1] <= dataW[15:8];
                    mem[addr+2] <= dataW[23:16];
                    mem[addr+3] <= dataW[31:24];
                end
            end
            default: mem[addr] <= 32'h0000_0000; // safe default, though ideally should never happen
        endcase
    end

    // ---------------- READ (comb) ----------------
    always_comb begin
        if (!MemRW && (addr < DEPTH_WORDS)) begin
            unique case (MemSize)
                2'b00: begin // byte
                    if (MemUnsigned)
                        dataR = {24'b0, mem[addr]};
                    else
                        dataR = {{24{mem[addr][7]}}, mem[addr]};
                end
                2'b01: begin // half-word
                    if (MemUnsigned)
                        dataR = {16'b0, mem[addr+1], mem[addr]};
                    else       
                        dataR = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
                end
                2'b10: begin // word
                    dataR = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                end
                default: dataR = 32'h0000_0000;
            endcase
        end else begin
            dataR = 32'h0000_0000;
        end
    end

endmodule