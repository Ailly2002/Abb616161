`include "define.v"
module cpu(
    input wire clk, rst,go,
    output wire [7:0] an,
    output wire [7:0] seg
//    output wire [15:0] num
);
    wire stop, ct;
    wire banch_j;
    wire branch_stall;
    wire IF_Flush;//��ָ֧����ˮ�߳�ˢ�ź�
    wire [`ADDR_BUS] pc_addr;//32λpc
    wire [`InstBus] ins;//32λָ�����
    wire[`ADDR_BUS]         pc_bus;//PCģ���ַ��
    wire[`ADDR_BUS]         pc_i;
    wire[`ADDR_BUS]         ir_idpc;//ID�λ�ȡpc��ַ��ͨ��
    wire[`ADDR_BUS]         pc_add_o;
    //����IF_ID��IDU
    wire [`InstBus] ifid_ins_o;
    wire [`ADDR_BUS] ifid_pcdr_o;
    //����IDģ���EXģ��
    wire[`AluOpBus] id_aluop_i;
    wire[`AluOpBus] id_aluop_o;
    wire[6:0] id_alufuns_i;
    wire[6:0] id_alufuns_o;
    wire[9:0] id_ex_vdb_i;
    wire[9:0] id_ex_vdb_o;
    wire[`AluSelBus] id_alusel_i;
    wire[`AluSelBus] id_alusel_o;
    wire[`RegBus] id_reg1_i;
    wire[`RegBus] id_reg1_o;
    wire[`RegBus] id_reg2_i;
    wire[`RegBus] id_reg2_o;
    wire          id_wreg_i;
    wire          id_wreg_o;
    wire[`RegAddr] id_wd_i;
    wire[`RegAddr] id_wd_o;
    //����IDģ���Regfileģ��
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddr] reg1_addr;
    wire[`RegAddr] reg2_addr;
    wire[4:0] id_mvdb;
    wire[`RegBus] rf_idvalid;
    wire instvalid;
    //����IDģ���EX_MUX
    wire [`ADDR_BUS]id_adpc_i;
    wire [`ADDR_BUS]id_adpc_o;
    //����PC_ADD��PC_MUX
    wire[`ADDR_BUS] pcad_o;
    //����ID��ADD_MUX
    wire [`RegBus]  jalr_rs1_i;
    wire [`RegBus]  jalr_rs1_o;
    wire            j_type_i;
    wire            j_type_o;
    //����ADD_MUX��EX_ADD
    wire[`RegBus] mx_ad_o;
    //����ID��EX_ADD
    wire[`RegBus] j_shift_i;
    wire[`RegBus] j_shift_o;
    //����EX_ADD��PC_MUX
    wire[`RegBus] ex_add_o;
    //����EXģ���WBģ��
    wire[9:0] ex_wb_vdb;
    wire ex_wreg;
    wire[`RegAddr] ex_wd;
    wire[`RegBus] ex_wdata;
    //����WBģ���Regfileģ��
    wire[9:0] wb_rf_vdb;
    wire[`RegAddr] wb_wd;
    wire wb_wreg;
    wire[`RegBus] wb_wdata;
    
    //����HDU
    wire [14:0] use_vdb;
    wire [14:0] unuse_vdb;
    
    //���ӵ������
    wire clk_use;
    wire[11:0] rg_digd;
    

//****ȡָ��****
    pc PC(
        .clk(clk), .rst(rst),.pc_Write(stop),.pc_set(pc_i),.pc_bus_o(pc_bus)
        );//ƫ���ֶ��и��棬���޸�
    mux2 ADD_MUX(
        .in1(pc_add_o),.in2(ex_add_o),.sel(banch_j),.out(pc_i)
        );
    pc_add PC_ADD(
        .pc_dr(pc_bus),.pc(pc_add_o)
        );
    insReg IR(
        .addr(pc_bus),.Ins(ins),.pcaddr(ir_idpc)
        );
    
    ifid IF_ID(
        .clk(clk),.rst(rst),
        .ifflush(IF_Flush),.Ins(ins),.pcaddr(ir_idpc),.ifidWrite(stop),
        .inst(ifid_ins_o),.pcadd(ifid_pcdr_o)
        );
//****����****
    cu IDU(
        .clk(clk),.rst(rst),
        .inst(ifid_ins_o),.pcadd(ifid_pcdr_o),
        .reg1_data(reg1_data),.reg2_data(reg2_data),.reg1_read(reg1_read),.reg2_read(reg2_read),.reg1_addr(reg1_addr),.reg2_addr(reg2_addr),
        .instvalid_o(instvalid),.use_vdb(use_vdb),.branch_stall(IF_Flush),.banch(ct_sel),.pcadd_o(id_adpc_i),.shift(j_shift_i),.rs1_o(jalr_rs1_i),.j_type(j_type_i),
        .aluop_o(id_aluop_i),.funct7(id_alufuns_i),.funct3(id_alusel_i),.reg1_o(id_reg1_i),.reg2_o(id_reg2_i),.wd_o(id_wd_i),.wreg_o(id_wreg_i)
        );
    hdu HDU(
        .clk(clk),.use_vdb(use_vdb),.unuse_vdb(unuse_vdb),.source_regs(id_ex_vdb_i),.instvalid_i(instvalid),.stop(stop)//.valid_bit(rf_idvalid),
        );
    //�Ĵ�����
    regfile GPR(
        .clk(clk), .rst(rst),
        .re1(reg1_read),.rs1_addr(reg1_addr),.rs1_data(reg1_data),.re2(reg2_read),.rs2_addr(reg2_addr),.rs2_data(reg2_data),
        .we(wb_wreg),.wd_addr(wb_wd),.wd_wdata(wb_wdata),.disp_dat(rg_digd)
        );
    idmux ID_MUX(
        .in1(id_adpc_i),.in2(jalr_rs1_i),.sel(j_type_i),.out(mx_ad_o)//j=0,JAL(in1) j=1,JALR
        );
    add ID_ADD(
        .in1(mx_ad_o),.shift(j_shift_i),.add_result(ex_add_o)
        );
    idex ID_EX(
        .clk(clk),.rst(rst),.idexWrite(stop),
        .aluop_i(id_aluop_i),.funct7_i(id_alufuns_i),.funct3_i(id_alusel_i),.reg1_i(id_reg1_i),.reg2_i(id_reg2_i),.wd_i(id_wd_i),.wreg_i(id_wreg_i),.source_regs_i(id_ex_vdb_i),
        .aluop_o(id_aluop_o),.funct7(id_alufuns_o),.funct3(id_alusel_o),.reg1_o(id_reg1_o),.reg2_o(id_reg2_o),.wd_o(id_wd_o),.wreg_o(id_wreg_o),.source_regs_o(id_ex_vdb_o)
        );
//****ִ��****
    banch BAC(
        .in1(ct_sel),.in2(ct),.banch(banch_j)//�ź� banch_jΪ1������ʹ��Add�Ľ����ΪPC+1��
        );//**in1δ�깤
    alu ALU(
        .clk(clk),.rst(rst),.source_regs(id_ex_vdb_o),
        .aluop_i(id_aluop_o),.funct7(id_alufuns_o),.funct(id_alusel_o),.wd_i(id_wd_o),.wreg_i(id_wreg_o),.in1(id_reg1_o), .in2(id_reg2_o),
        .ct(ct),.ex_chvdb(ex_wb_vdb),.wd_o(ex_wd),.wreg_o(ex_wreg),.z(ex_wdata)
        );
//****��д****
    wbu WB(
        .rst(rst), .clk(clk),
        .ex_chvdb(ex_wb_vdb),.ex_wreg(ex_wreg),.ex_addr(ex_wd),.data_in(ex_wdata),
        .wb_wreg(wb_wreg),.wb_addr(wb_wd),.data_out(wb_wdata),.unuse_vdb(unuse_vdb)
        );
//****��ʾ�ϰ�****
    clk_use CLU(
        .clk_sys(clk),.go(go),.clr(rst),.clk_use(clk_use)
        );
    digit_tubes DIG(
        .clk(clk_use),.rst(rst),.disp_dat(rg_digd),.seg(num),.an(an)
        );
    
endmodule

