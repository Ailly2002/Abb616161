`include "define.v"
module cpu(
    input wire clk, rst,go,
    output wire [7:0] an,
    output wire [7:0] seg
//    output wire [15:0] num
);
    wire stop, ct;
    wire [`ADDR_BUS] pc_addr;//32位pc
    wire [`InstBus] ins;//32位指令读出
    wire[`ADDR_BUS]         pc_bus;//PC模块地址线
    wire[`ADDR_BUS]         pc_i;
    wire[`ADDR_BUS]         ir_idpc;//ID段获取pc地址的通道
    wire[`ADDR_BUS]         pc_add_o;
    //连接IF_ID和IDU
    wire [`InstBus] ifid_ins_o;
    wire [`ADDR_BUS] ifid_pcdr_o;
    //连接ID模块和EX模块
    wire[`AluOpBus] id_aluop;
    wire[6:0] id_alufuns;
    wire[9:0] id_ex_vdb;
    wire[`AluSelBus] id_alusel;//
    wire[`RegBus] id_reg1;//
    wire[`RegBus] id_reg2;//
    wire          id_wreg;//
    wire[`RegAddr] id_wd;//
    //连接ID模块和Regfile模块
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddr] reg1_addr;
    wire[`RegAddr] reg2_addr;
    wire[4:0] id_mvdb;
    wire[`RegBus] rf_idvalid;
    
    //连接ID模块和EX_MUX
    wire [`ADDR_BUS]id_adpc;
    //连接PC_ADD和PC_MUX
    wire[`ADDR_BUS] pcad_o;
    //连接ID和ADD_MUX
    wire [`RegBus]  jalr_rs1;
    wire            j_type;
    //连接ADD_MUX和EX_ADD
    wire[`RegBus] mx_ad_o;
    //连接ID和EX_ADD
    wire[`RegBus] j_shift;
    //连接EX_ADD和PC_MUX
    wire[`RegBus] ex_add_o;
    //连接EX模块和WB模块
    wire[9:0] ex_wb_vdb;
    wire ex_wreg;
    wire[`RegAddr] ex_wd;
    wire[`RegBus] ex_wdata;
    //连接WB模块和Regfile模块
    wire[9:0] wb_rf_vdb;
    wire[`RegAddr] wb_wd;
    wire wb_wreg;
    wire[`RegBus] wb_wdata;
    
    //连接HDU
    wire [14:0] use_vdb;
    wire [14:0] unuse_vdb;
    
    //连接到数码管
    wire clk_use;
    wire[11:0] rg_digd;
    

//****取指令****
    pc PC(
        .clk(clk), .rst(rst), .ct(ct),.pc_Write(stop),.pc_set(pc_i),.pc_bus_o(pc_bus)
        );//偏移字段有干涉，待修改
    mux2 ADD_MUX(
        .in1(ex_add_o),.in2(pc_add_o),.sel(go),.out(pc_i)
        );
    pc_add PC_ADD(
        .pc_dr(pc_bus),.pc(pc_add_o)
        );
    insReg IR(
        .addr(pc_bus),.Ins(ins),.pcaddr(ir_idpc)
        );
    
    ifid IF_ID(
        .clk(clk),.Ins(ins),.pcaddr(ir_idpc),.ifidWrite(stop),.inst(ifid_ins_o),.pcadd(ifid_pcdr_o)
        );
//****译码****
    cu IDU(
        .rst(rst),.inst(ifid_ins_o),.pcadd(ifid_pcdr_o),.valid_bit(rf_idvalid),
        .reg1_data(reg1_data),.reg2_data(reg2_data),.reg1_read(reg1_read),.reg2_read(reg2_read),.reg1_addr(reg1_addr),.reg2_addr(reg2_addr),
        .use_vdb(use_vdb),.pcadd_o(id_adpc),.shift(j_shift),.rs1_o(jalr_rs1),.j_type(j_type),
        .aluop_o(id_aluop),.funct7(id_alufuns),.funct3(id_alusel),.reg1_o(id_reg1),.reg2_o(id_reg2),.wd_o(id_wd),.wreg_o(id_wreg)
        );
    hdu HDU(
        .use_vdb(use_vdb),.unuse_vdb(unuse_vdb),.valid_bit(rf_idvalid),.stop(stop)
        );
    //寄存器堆
    regfile GPR(
        .clk(clk), .rst(rst),.wb_chvdb(wb_rf_vdb),
        .re1(reg1_read),.rs1_addr(reg1_addr),.rs1_data(reg1_data),.re2(reg2_read),.rs2_addr(reg2_addr),.rs2_data(reg2_data),
        .we(wb_wreg),.wd_addr(wb_wd),.wd_wdata(wb_wdata),.disp_dat(rg_digd)
        );
//****执行****
    mux2 EX_MUX(
        .in1(id_adpc),.in2(jalr_rs1),.sel(j_type),.out(mx_ad_o)//j=0,JAL(in1) j=1,JALR
        );
    add EX_ADD(
        .in1(mx_ad_o),.shift(j_shift),.add_result(ex_add_o)
        );
    alu ALU(
        .clk(clk),.rst(rst),.source_regs(id_ex_vdb),
        .aluop_i(id_aluop),.funct7(id_alufuns),.funct(id_alusel),.wd_i(id_wd),.wreg_i(id_wreg),.in1(id_reg1), .in2(id_reg2),
        .ct(ct),.ex_chvdb(ex_wb_vdb),.wd_o(ex_wd),.wreg_o(ex_wreg),.z(ex_wdata)
        );
//****回写****
    wbu WB(
        .rst(rst), .clk(clk),
        .ex_chvdb(ex_wb_vdb),.ex_wreg(ex_wreg),.ex_addr(ex_wd),.data_in(ex_wdata),
        .wb_chvdb(wb_rf_vdb),.wb_wreg(wb_wreg),.wb_addr(wb_wd),.data_out(wb_wdata),.unuse_vdb(unuse_vdb)
        );
//****显示上板****
    clk_use CLU(
        .clk_sys(clk),.go(go),.clr(rst),.clk_use(clk_use)
        );
    digit_tubes DIG(
        .clk(clk_use),.rst(rst),.disp_dat(rg_digd),.seg(num),.an(an)
        );
    
endmodule

