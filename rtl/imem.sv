module IMEM #(
    parameter int    DEPTH_WORDS = 1024
)(
             input  logic rst_n,
             input  logic [31:0] addr,
             output logic [31:0] inst
);
  // Dung lượng: 1024 word (4KB)
  logic [7:0] inst_mem [0:DEPTH_WORDS-1];

  // ==== đọc instruction ====
  always_comb begin
    if (!rst_n)
      inst = 32'd0;
    else if (addr[31:2] < DEPTH_WORDS)
      inst = {inst_mem[addr[31:2]], inst_mem[addr[31:2]+1], inst_mem[addr[31:2]+2], inst_mem[addr[31:2]+3]};
    else
      inst = 32'h00000013;
  end
  // ==== nạp nội dung chương trình ====
  initial begin
      string path;
      int file;

      file = $fopen("../../rtl_pipelined/instmem_path.txt", "r");

      if (file)
          $display("Instr file opened successfully");
      else
          $display("File could not be opened, %0d", file);

      $fgets(path, file);
      $display("path: %s", path);

      $fclose(file);

      $display("Loading instruction memory...");
      $readmemh(path, inst_mem);
      $display("Instruction memory loaded....");
  end

endmodule
