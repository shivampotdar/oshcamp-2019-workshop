import riscv_defines::*;

module riscv_str_ops(
    input   logic                     clk,
    input   logic                     enable_i,
    input   logic [STR_OP_WIDTH-1:0]  operator_i,
    input   logic [31:0]              operand_i,
    output  logic [31:0]              result_o
);

// always_comb begin
//     result_o = enable_i ? operand_i : 32'b0;
// end

always_ff @(posedge clk)
begin
    if (enable_i) begin
        logic [7:0] operand_i_byte[4];
        foreach(operand_i_byte[i]) begin
            operand_i_byte[i] = operand_i[8*i +: 8];
            case(operator_i)
                STR_OP_UPPER: begin
                    if(operand_i_byte[i] >= 97 && operand_i_byte[i] <= 122)
                        result_o[8*i +: 8] <= operand_i_byte[i] - 32;
                    else
                        result_o[8*i +: 8] <= operand_i_byte[i];
                end
                
                STR_OP_LOWER: begin
                    if(operand_i_byte[i] >= 65 && operand_i_byte[i] <= 92)
                        result_o[8*i +: 8] <= operand_i_byte[i] + 32;
                    else
                        result_o[8*i +: 8] <= operand_i_byte[i];
                    //$display("%t: Exec Lower instruction", $time);
                end

                STR_OP_LEET:
                    $display("%t: Exec Leet speak instruction", $time);
                STR_OP_ROT13:
                    $display("%t: Exec Rot13 instruction", $time);
            endcase
        end
    end
end

endmodule
