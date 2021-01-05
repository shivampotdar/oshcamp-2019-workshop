import riscv_defines::*;

module riscv_str_ops(
    input   logic                       clk,
    input   logic                       rst_n,
    input   logic                       enable_i,
    input   logic [STR_OP_WIDTH-1:0]    operator_i,
    input   logic [31:0]                operand_i,
    output  logic [31:0]                result_o,

    output  logic                       ready_o,
    input   logic                       ex_ready_i
);

logic [31:0] result;

always_comb begin
    if(enable_i) begin
        result_o = 32'hDEADBEEF;

        if(operator_i == STR_OP_UPPER)
            result_o = result;
        if(operator_i == STR_OP_LEET && leet_CS == FINISH)
            result_o = leet_intermediate;
    end
    // result_o = enable_i ? operand_i : 32'b0;
end

always_ff @(posedge clk)
begin
    if (enable_i) begin
        logic [7:0] operand_i_byte[4];
        foreach(operand_i_byte[i]) begin
            operand_i_byte[i] = operand_i[8*i +: 8];
            case(operator_i)
                STR_OP_UPPER: begin
                    if(operand_i_byte[i] >= 97 && operand_i_byte[i] <= 122)
                        result[8*i +: 8] <= operand_i_byte[i] - 32;
                    else
                        result[8*i +: 8] <= operand_i_byte[i];
                end
                
                STR_OP_LOWER: begin
                    if(operand_i_byte[i] >= 65 && operand_i_byte[i] <= 92)
                        result[8*i +: 8] <= operand_i_byte[i] + 32;
                    else
                        result[8*i +: 8] <= operand_i_byte[i];
                    //$display("%t: Exec Lower instruction", $time);
                end

                // STR_OP_LEET:
                //     //$display("%t: Exec Leet speak instruction", $time);
                //     result_o
                // STR_OP_ROT13:
                //     $display("%t: Exec Rot13 instruction", $time);
            endcase
        end
    end

    case(leet_CS)
        IDLE: begin
            if (operator_i == STR_OP_LEET && enable_i)
                leet_intermediate <= operand_i;            
        end

        STEP0: begin
            logic [7:0] char_leet[4];
            foreach(char_leet[i]) begin
                char_leet[i] = leet_intermediate[8*i +: 8];
                if(char_leet[i] == 69 || char_leet[i] == 101)
                    char_leet[i] = 51;
                leet_intermediate[8*i +: 8] <= char_leet[i];
            end
        end

        STEP1: begin
            logic [7:0] char_leet[4];
            foreach(char_leet[i]) begin
                char_leet[i] = leet_intermediate[8*i +: 8];
                if(char_leet[i] == 83 || char_leet[i] == 115)
                    char_leet[i] = 53;
                leet_intermediate[8*i +: 8] <= char_leet[i];
            end
        end

        STEP2: begin
            logic [7:0] char_leet[4];
            foreach(char_leet[i]) begin
                char_leet[i] = leet_intermediate[8*i +: 8];
                if(char_leet[i] == 76 || char_leet[i] == 108)
                    char_leet[i] = 49;
                leet_intermediate[8*i +: 8] <= char_leet[i];
            end
        end
    endcase

end

enum logic [2:0] {IDLE, STEP0, STEP1, STEP2, FINISH} leet_CS, leet_NS;

logic leet_active;
logic leet_ready;
logic [31:0] leet_intermediate;     // register to store the intermediate values

// state machine to implement the multi cycle behavior of the LEET op
// it is divided in multiple STEPs + IDLE and FINIISH make the states 
// Also has a handshaking of sorts with the ex_stage - enter STEP0 when OP is seen
// and come out of FINISH when ex says it is ready

always_comb begin
    leet_ready  =   1'b0;
    leet_NS     =   leet_CS;
    leet_active =   1'b1;

    case (leet_CS)
        IDLE: begin
            leet_active     =   1'b0;
            leet_ready      =   1'b1;

            if (operator_i == STR_OP_LEET && enable_i) begin
                leet_ready  =   1'b0;
                leet_NS     =   STEP0;

            end
        end
        
        STEP0: begin            
            leet_NS         =   STEP1;
        end

        STEP1: begin
            leet_NS         =   STEP2;
        end

        STEP2: begin
            leet_NS         =   FINISH;
        end

        FINISH: begin
            leet_ready      =   1'b1;
            if (ex_ready_i)
                leet_NS     =   IDLE;
        end
    endcase
end

assign ready_o = leet_ready;

// IDLE at reset and go to next state on clock pulse
always_ff @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
        leet_CS     <=  IDLE;
    else
        leet_CS     <=  leet_NS;
end

endmodule
