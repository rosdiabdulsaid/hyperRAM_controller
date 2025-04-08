module rdreg_stm(
    input  wire clk,
    input  wire rst,
    input  wire stm_start,
    output reg  stm_end,
    output reg  oe,
    output reg  oe_clk,
    output reg  csn,
    input  wire rwds_in,
    output wire [15:0] datain,
    input  wire [15:0] dataout,
    input  wire [47:0] casig,
    output reg         valid,
    output reg  [15:0] dataoutr
);

typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_CA,
    STATE_RUN,
    STATE_DONE
  } fsm_state_e;

reg [3:0] counter;
fsm_state_e state;
reg [15:0] buffer_out[0:2];
// reg [15:0] dataoutr;
always@(posedge clk) begin
    if(rst) begin
        stm_end <= 0;
        counter <= 0;
        state   <= STATE_IDLE;
        oe      <= 0;
        oe_clk  <= 0;
        csn     <= 1;
        valid   <= 0;
        for (int i =0 ;i<3 ;i++ ) begin
            buffer_out[i] <= 0;
        end
    end else begin
        case (state)
            STATE_IDLE: begin
                counter <= 0;
                stm_end <= 0;
                buffer_out[0] <= casig[47:32];
                buffer_out[1] <= casig[31:16];
                buffer_out[2] <= casig[15:0];
                csn   <= 1;
                valid <= 0;
                if(stm_start) begin
                    state <= STATE_CA;
                    csn   <= 0;
                end
            end
            STATE_CA: begin
                if (counter == 4) begin
                    state <= STATE_RUN;
                    counter <= 0;
                    oe <= 0;
                end else
                if (counter > 0 && counter < 4) begin
                    counter <= counter + 1;
                    buffer_out[0] <= buffer_out[1];
                    buffer_out[1] <= buffer_out[2];
                    buffer_out[2] <= 16'h0000;
                    oe_clk <= 1;
                end else
                if (rwds_in) begin
                    oe <= 1;
                    oe_clk <= 0;
                    counter <= 1;
                end
            end
            STATE_RUN: begin
                if (counter == 14) begin
                    state <= STATE_DONE;
                    stm_end <= 1;
                    counter <= 0;
                    csn     <= 1;
                    dataoutr <= dataout;
                    valid    <= 1;
                end begin
                    counter <= counter + 1;
                end
            end
            STATE_DONE: begin
                state <= STATE_IDLE;
                oe_clk <= 0;
                valid  <= 0;
            end 
            default: state <= STATE_IDLE;
        endcase
    end
end

// altsource_probe_top #(
//     .sld_auto_instance_index ("YES"),
//     .sld_instance_index      (0),
//     .instance_id             ("NONE"),
//     .probe_width             (16),
//     .source_width            (0),
//     .source_initial_value    ("0"),
//     .enable_metastability    ("NO")
// ) sp_inst (
//     .probe      (dataoutr),  //  probes.probe
//     .source_ena (1'b1)    // (terminated)
// );
        

assign datain = buffer_out[0];

endmodule

module wrmem_stm(
    input wire clk,
    input wire rst,
    input wire stm_start,
    output reg stm_end,
    output reg  oe,
    output reg  oe_clk,
    output reg  csn,
    input  wire rwds_in,
    output wire [15:0] datain,
    output reg rwds_out,
    output reg rwds_oe,
    input  wire [47:0] casig
);

typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_CA,
    STATE_RUN,
    STATE_DONE
  } fsm_state_e;

reg [4:0] counter;
fsm_state_e state;
reg [15:0] buffer_out[0:18];
wire [15:0] buffer_outw[0:15];

altsource_probe_top #(
    .sld_auto_instance_index ("YES"),
    .sld_instance_index      (0),
    .instance_id             ("NONE"),
    .probe_width             (0),
    .source_width            (256),
    .source_initial_value    ("0"),
    .enable_metastability    ("NO")
) sp_inst (
    .source      ({ buffer_outw[0],
                    buffer_outw[1],
                    buffer_outw[2],
                    buffer_outw[3],
                    buffer_outw[4],
                    buffer_outw[5],
                    buffer_outw[6],
                    buffer_outw[7],
                    buffer_outw[8],
                    buffer_outw[9],
                    buffer_outw[10],
                    buffer_outw[11],
                    buffer_outw[12],
                    buffer_outw[13],
                    buffer_outw[14],
                    buffer_outw[15]}),  //  probes.probe
    .source_ena (1'b1)    // (terminated)
);
    

always@(posedge clk) begin
    if(rst) begin
        stm_end  <= 0;
        counter  <= 0;
        state    <= STATE_IDLE;
        oe       <= 0;
        oe_clk   <= 0;
        csn      <= 1;
        rwds_out <= 0;
        rwds_oe  <= 0;
        for (int i =0 ;i<3 ;i++ ) begin
            buffer_out[i] <= 0;
        end
    end else begin
        case (state)
            STATE_IDLE: begin
                counter <= 0;
                stm_end <= 0;
                buffer_out[0]   <= casig[47:32];
                buffer_out[1]   <= casig[31:16];
                buffer_out[2]   <= casig[15:0];
                buffer_out[3]  <=  buffer_outw[0];  
                buffer_out[4]  <=  buffer_outw[1];
                buffer_out[5]  <=  buffer_outw[2];
                buffer_out[6]  <=  buffer_outw[3];
                buffer_out[7]  <=  buffer_outw[4];
                buffer_out[8]  <=  buffer_outw[5];
                buffer_out[9]  <=  buffer_outw[6];
                buffer_out[10] <=  buffer_outw[7];
                buffer_out[11] <=  buffer_outw[8];
                buffer_out[12] <=  buffer_outw[9];
                buffer_out[13] <=  buffer_outw[10];
                buffer_out[14] <=  buffer_outw[11];
                buffer_out[15] <=  buffer_outw[12];
                buffer_out[16] <=  buffer_outw[13];
                buffer_out[17] <=  buffer_outw[14];
                buffer_out[18] <=  buffer_outw[15];
                csn   <= 1;
                if (stm_start) begin
                    state <= STATE_CA;
                    csn   <= 0;
                end
            end
            STATE_CA: begin
                if (counter == 4) begin
                    state   <= STATE_RUN;
                    counter <= 0;
                    oe      <= 0;
                end else
                if (counter > 0 && counter < 4) begin
                    for (int i = 0;i< 18 ;i++ ) begin
                        buffer_out[i] <= buffer_out[i+1];
                    end
                    buffer_out[18]  <= 'h0;
                    oe              <= 1;
                    oe_clk          <= 1;
                    counter         <= counter + 1;
                end else
                if (rwds_in) begin
                    oe <= 1;
                    oe_clk <= 0;
                    counter <= 1;
                end
            end
            STATE_RUN: begin
                if (counter == 29) begin
                        state   <= STATE_DONE;
                        counter <= 0;
                        stm_end <= 1;
                        csn     <= 1;
                        oe      <= 0;
                        oe_clk  <= 0;
                        rwds_oe <= 0;
                    end else if (counter > 12) begin
                        for (int i = 0;i< 18 ;i++ ) begin
                            buffer_out[i] <= buffer_out[i+1];
                        end
                        
                        buffer_out[18]  <= 'h0;
                        counter         <= counter + 1;
                        oe              <= 1;
                        oe_clk          <= 1;
                        rwds_out        <= 0;
                        rwds_oe         <= 1;
                    end else begin
                        counter <= counter + 1;
                    end
            end
            STATE_DONE: begin
                state   <= STATE_IDLE;
                oe_clk  <= 0;
            end
            default: state <= STATE_IDLE;

        endcase
    end
end

assign datain = buffer_out[0];

endmodule

module wrreg_stm(
    input wire clk,
    input wire rst,
    input wire stm_start,
    output wire stm_end
);


endmodule

module rdmem_stm(
    input  wire clk,
    input  wire rst,
    input  wire stm_start,
    output reg  stm_end,
    output reg  oe,
    output reg  oe_clk,
    output reg  csn,
    input  wire rwds_in,
    output wire [15:0] datain,
    input  wire [15:0] dataout,
    output reg [15:0] dataoutr,
    output reg  valid,
    input  wire [47:0] casig
);


typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_CA,
    STATE_RUN,
    STATE_DONE
  } fsm_state_e;

reg [5:0] counter;
fsm_state_e state;
reg [15:0] buffer_out[0:2];


always@(posedge clk) begin
    if(rst) begin
        stm_end <= 0;
        counter <= 0;
        state   <= STATE_IDLE;
        oe      <= 0;
        oe_clk  <= 0;
        csn     <= 1;
        valid   <= 0;
        for (int i =0 ;i<3 ;i++ ) begin
            buffer_out[i] <= 0;
        end
    end else begin
        case (state)
            STATE_IDLE: begin
                counter <= 0;
                stm_end <= 0;
                buffer_out[0] <= casig[47:32];
                buffer_out[1] <= casig[31:16];
                buffer_out[2] <= casig[15:0];
                csn   <= 1;
                if(stm_start) begin
                    state <= STATE_CA;
                    csn   <= 0;
                end
            end
            STATE_CA: begin
                if (counter == 4) begin
                    state <= STATE_RUN;
                    counter <= 0;
                    oe <= 0;
                end else
                if (counter > 0 && counter < 4) begin
                    counter <= counter + 1;
                    buffer_out[0] <= buffer_out[1];
                    buffer_out[1] <= buffer_out[2];
                    buffer_out[2] <= 16'h0000;
                    oe_clk <= 1;
                end else
                if (rwds_in) begin
                    oe <= 1;
                    oe_clk <= 0;
                    counter <= 1;
                end
            end
            STATE_RUN: begin
                if (counter == 32) begin
                    state <= STATE_DONE;
                    stm_end <= 1;
                    counter <= 0;
                    csn     <= 1;
                    valid   <= 0;
                end else
                if (counter > 15) begin
                    dataoutr <= dataout;
                    valid    <= 1;
                    counter <= counter + 1;
                end else
                begin
                    counter <= counter + 1;
                end
            end
            STATE_DONE: begin
                state <= STATE_IDLE;
                oe_clk <= 0;
            end 
            default: state <= STATE_IDLE;
        endcase
    end
end

// altsource_probe_top #(
//     .sld_auto_instance_index ("YES"),
//     .sld_instance_index      (0),
//     .instance_id             ("NONE"),
//     .probe_width             (17),
//     .source_width            (0),
//     .source_initial_value    ("0"),
//     .enable_metastability    ("NO")
// ) sp_inst (
//     .probe      ({valid,dataoutr}),  //  probes.probe
//     .source_ena (1'b1)    // (terminated)
// );
        

assign datain = buffer_out[0];

endmodule
