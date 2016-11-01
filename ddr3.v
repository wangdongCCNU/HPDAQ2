`timescale 1ns / 1ps

module top
(
  // Inouts
 inout [63:0]                         ddr3_dq,
 inout [7:0]                        ddr3_dqs_n,
 inout [7:0]                        ddr3_dqs_p,

 // Outputs
 output [13:0]                       ddr3_addr,
 output [2:0]                        ddr3_ba,
 output                              ddr3_ras_n,
 output                              ddr3_cas_n,
 output                              ddr3_we_n,
 output                              ddr3_reset_n,
 output                              ddr3_ck_p,
 output                              ddr3_ck_n,
 output                              ddr3_cke,
 output                              ddr3_cs_n,
 output [7:0]                        ddr3_dm,
 output                              ddr3_odt,

 // Inputs
 
 // Differential system clocks
 input                                        sys_clk_p,
 input                                        sys_clk_n,
 //output                                       tg_compare_error,
 //output                                       init_calib_complete,
    
 // System reset - Default polarity of sys_rst pin is Active Low.
 // System reset polarity will change based on the option 
 // selected in GUI.
 input                                        sys_rst
    );


// Wire declarations
 (* MARK_DEBUG="true" *) wire                                   app_rdy;
 (* MARK_DEBUG="true" *) wire                                   app_wdf_rdy;
 (* MARK_DEBUG="true" *) wire  [511:0]                          app_rd_data;  
 (* MARK_DEBUG="true" *) wire                                   app_rd_data_valid;
 (* MARK_DEBUG="true" *) wire [27:0]                           app_addr;
 (* MARK_DEBUG="true" *) wire [2:0]                            app_cmd;
 (* MARK_DEBUG="true" *) wire                                  app_en;
 (* MARK_DEBUG="true" *) wire [511:0]                          app_wdf_data;
 (* MARK_DEBUG="true" *) wire                                  app_wdf_end;
 (* MARK_DEBUG="true" *) wire [63:0]                           app_wdf_mask;
 (* MARK_DEBUG="true" *) wire                                  app_wdf_wren;
 (* MARK_DEBUG="true" *) wire                                  init_calib_complete;
      
 reg [27:0]                           app_addr_a;
 reg [2:0]                            app_cmd_a;
 reg                                  app_en_a;
 reg [511:0]                          app_wdf_data_a;
 reg                                  app_wdf_end_a;
 reg [63:0]                           app_wdf_mask_a;
 reg                                  app_wdf_wren_a;

  parameter START  = 4'b0001;
  parameter SWRITE = 4'b0010;
  parameter SREAD  = 4'b0100;
  parameter SSTOP  = 4'b1000;
  reg[4:0]   cstate;
  
  always @(posedge clk or posedge rst)
      if(rst) cstate <= START;
      else begin
          case(cstate)
              START:begin
                  if(init_calib_complete)
                  begin
                      if((app_wdf_rdy)&&(!app_rdy))
                      begin
                      app_en_a <= 1'b1; app_cmd_a <= 3'b000; 
                      cstate <= SWRITE;
                      end
                  end
                  
                  else cstate <= START;
              end
              SWRITE: begin
                  if((app_rdy)&&(app_wdf_rdy))
                  begin
                  app_wdf_wren_a <= 1'b1; app_wdf_end_a <= 1'b1; 
                  app_addr_a <= 28'h0000f00; 
                  app_wdf_data_a <= 128'h50805080;
                  cstate <= SREAD;
                  end
                  
                  else if((!app_rdy) && (app_wdf_rdy))
                  begin
                  app_wdf_wren_a <= 1'b0; app_wdf_end_a <= 1'b0;
                  cstate <= SWRITE;
                  end
                  
                  else
                  cstate <= START;
              end
              SREAD: begin
                  if(app_rdy )
                  begin
                  app_en_a <= 1'b1; app_cmd_a <= 3'b001;
                  app_addr_a <= 28'h0000f00; 
                  cstate <= SSTOP;
                  end
                  else cstate <= SREAD;
              end
              SSTOP:  cstate <= START;
              default: cstate <= START;
          endcase
      end
      
assign         app_addr = app_addr_a;   
assign         app_cmd = app_cmd_a;
assign         app_en = app_en_a;
assign         app_wdf = app_wdf_data_a;
assign         app_wdf_end = app_wdf_end_a;
assign         app_wdf_mask = app_wdf_mask_a;
assign         app_wdf_wren = app_wdf_wren_a;

 //---------- mig instance
      mig_7series_0 u_mig_7series_0 (
    
        // Memory interface ports
        .ddr3_addr                      (ddr3_addr),  // output [13:0]        ddr3_addr
        .ddr3_ba                        (ddr3_ba),  // output [2:0]        ddr3_ba
        .ddr3_cas_n                     (ddr3_cas_n),  // output            ddr3_cas_n
        .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]        ddr3_ck_n
        .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]        ddr3_ck_p
        .ddr3_cke                       (ddr3_cke),  // output [0:0]        ddr3_cke
        .ddr3_ras_n                     (ddr3_ras_n),  // output            ddr3_ras_n
        .ddr3_reset_n                   (ddr3_reset_n),  // output            ddr3_reset_n
        .ddr3_we_n                      (ddr3_we_n),  // output            ddr3_we_n
        .ddr3_dq                        (ddr3_dq),  // inout [63:0]        ddr3_dq
        .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [7:0]        ddr3_dqs_n
        .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [7:0]        ddr3_dqs_p
        .init_calib_complete            (init_calib_complete),  // output            init_calib_complete      
        .ddr3_cs_n                      (ddr3_cs_n),  // output [0:0]        ddr3_cs_n
        .ddr3_dm                        (ddr3_dm),  // output [7:0]        ddr3_dm
        .ddr3_odt                       (ddr3_odt),  // output [0:0]        ddr3_odt
        // Application interface ports
        .app_addr                       (app_addr),  // input [27:0]        app_addr
        .app_cmd                        (app_cmd),  // input [2:0]        app_cmd
        .app_en                         (app_en),  // input                app_en
        .app_wdf_data                   (app_wdf_data),  // input [511:0]        app_wdf_data
        .app_wdf_end                    (app_wdf_end),  // input                app_wdf_end
        .app_wdf_wren                   (app_wdf_wren),  // input                app_wdf_wren
        .app_rd_data                    (app_rd_data),  // output [511:0]        app_rd_data
        .app_rd_data_end                (),  // output            app_rd_data_end
        .app_rdy                        (app_rdy),  // output            app_rdy
        .app_wdf_rdy                    (app_wdf_rdy),  // output            app_wdf_rdy
        .app_sr_req                     (1'b0),  // input            app_sr_req
        .app_ref_req                    (1'b0),  // input            app_ref_req
        .app_zq_req                     (1'b0),  // input            app_zq_req
        .app_sr_active                  (),  // output            app_sr_active
        .app_ref_ack                    (),  // output            app_ref_ack
        .app_zq_ack                     (),  // output            app_zq_ack
        .ui_clk                         (clk),  // output            ui_clk
        .ui_clk_sync_rst                (),  // output            ui_clk_sync_rst
        .app_wdf_mask                   (16'h0000),  // input [63:0]        app_wdf_mask
        // System Clock Ports
        .sys_clk_p                       (sys_clk_p),  // input                sys_clk_p
        .sys_clk_n                       (sys_clk_n),  // input                sys_clk_n
        .sys_rst                        (rst) // input sys_rst
        );
endmodule
