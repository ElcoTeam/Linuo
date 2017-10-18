--订单完工过账ERP接口表
IF OBJECT_ID('ERP_WO_REPORT_COMPLETE') is not null
DROP TABLE ERP_WO_REPORT_COMPLETE;
CREATE TABLE [dbo].[ERP_WO_REPORT_COMPLETE] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [WoID]               INT             NOT NULL,                        --MES系统工单ID
    [AUFNR]              VARCHAR  (50)   NOT NULL,                        --订单编号
    [MATNR]              VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [MAKTX]              NVARCHAR (50)   NOT NULL,                        --产品的物料描述
    [GAMNG]              INT             NOT NULL DEFAULT (0),            --订单产量
    [FinishQty]          INT             NOT NULL DEFAULT (0),            --已经完工数量(需要报工数量)
    [ErpCfmStatus]       INT             NOT NULL DEFAULT (-1),           --订单报工状态:  -1:新增,  0:待处理, 1:进行中, 2:失败, 3:已完成 [BAPI_PRODORDCONF_CREATE_HDR]
    [ErpCfmMessage]      NVARCHAR (50)       NULL DEFAULT (N''),          --订单报工信息:  ERP过账反馈信息
    [MesCfmStatus]       INT             NOT NULL DEFAULT (-1),           --MES取回状态:  -1:新增,  0:待处理, 1:进行中, 2:失败, 3:已完成
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间
    [MesCreateUser]      NVARCHAR (50)   NOT NULL DEFAULT (''),           --创建用户
    [MesModifyTime]      DATETIME        NOT NULL DEFAULT GETDATE()       --更新时间
);

--订单的计件物料扣除接口表
IF OBJECT_ID('ERP_WO_Material_Transfer') is not null
DROP TABLE ERP_WO_Material_Transfer;
CREATE TABLE [dbo].[ERP_WO_Material_Transfer] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [WoID]               INT             NOT NULL,                        --MES系统工单ID
    [AUFNR]              VARCHAR  (50)   NOT NULL,                        --订单编号
    [MATNR]              VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [MAKTX]              NVARCHAR (50)   NOT NULL,                        --产品的物料描述
    [GAMNG]              INT             NOT NULL DEFAULT (0),            --订单产量
    [FinishQty]          INT             NOT NULL DEFAULT (0),            --订单数量
    [ErpMvtStatus]       INT             NOT NULL DEFAULT (-1),           --订单报工状态:  -1:新增,  0:待处理, 1:进行中, 2:失败, 3:已完成 [ZME_GOODSMVT_CREATE]
    [ErpMvtMessage]      NVARCHAR (50)       NULL DEFAULT (N''),          --订单报工信息:  ERP物料扣除反馈信息
    [MesMvtStatus]       INT             NOT NULL DEFAULT (-1),           --MES取回状态:  -1:新增,  0:待处理, 1:进行中, 2:失败, 3:已完成
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间
    [MesCreateUser]      NVARCHAR (50)   NOT NULL DEFAULT (''),           --创建用户
    [MesModifyTime]      DATETIME        NOT NULL DEFAULT GETDATE()       --更新时间
);

--ERP生产工单(订单)
IF OBJECT_ID('ERP_WO_List') is not null
DROP TABLE ERP_WO_List;
CREATE TABLE [dbo].[ERP_WO_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [AUFNR]              VARCHAR  (50)   NOT NULL,                        --订单编号
    [MATNR]              VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [MAKTX]              NVARCHAR (50)   NOT NULL,                        --产品的物料描述
    [GAMNG]              NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --订单产量
    [ERDAT]              DATETIME        NOT NULL,                        --订单创建时间
    [GSTRP]              DATETIME        NOT NULL,                        --订单开始时间
    [GLTRP]              DATETIME        NOT NULL,                        --订单完成时间
    [FTRMI]              DATETIME        NOT NULL,                        --订单发行时间
    [WERKS]              VARCHAR  (50)   NOT NULL DEFAULT (''),           --生产工厂
    [AUART]              VARCHAR  (50)   NOT NULL DEFAULT (''),           --订单类型
    [TXT30]              VARCHAR  (50)   NOT NULL DEFAULT (''),           --订单状态
    [OBJNR]              VARCHAR  (30)   NOT NULL DEFAULT (''),           --对象号
    [ZTYPE]              VARCHAR  (50)   NOT NULL DEFAULT (''),           --订单类别
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间(MES导入时间)
    [MesCreateUser]      NVARCHAR (50)   NOT NULL DEFAULT (N'SAP'),       --创建用户
    [MesModifyTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [MesModifyUser]      NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [MesStatus]          INT             NOT NULL DEFAULT (0)             --订单状态: 0:待生产, 1:产前调整中, 2:生产进行中, 3:已完成
);

--ERP生产工单用料表
IF OBJECT_ID('ERP_WO_MTL_List') is not null
DROP TABLE ERP_WO_MTL_List;
CREATE TABLE [dbo].[ERP_WO_MTL_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [RSNUM]              NUMERIC  (10,0)     NULL,                        --预留(需求编号)
    [RSPOS]              INT                 NULL,                        --预留(项目编号)
    [AUFNR]              VARCHAR  (50)   NOT NULL,                        --订单编号
    [POSNR]              INT             NOT NULL DEFAULT (0),            --行号
    [MATNR]              VARCHAR  (50)   NOT NULL,                        --原料编码
    [MAKTX]              NVARCHAR (50)   NOT NULL,                        --原料描述
    [ERFMG]              NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --用量
    [ERFME]              NVARCHAR (10)   NOT NULL DEFAULT (N'个'),        --用料计量单位
    [VORNR]              NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序编号
    [ARBPL]              VARCHAR  (50)   NOT NULL DEFAULT (N''),          --工作中心
    [KTEXT]              NVARCHAR (50)   NOT NULL DEFAULT (N''),          --短描述(工作中心短描述)
    [LGORT]              VARCHAR  (50)   NOT NULL DEFAULT (N''),          --库位
    [DUMPS]              VARCHAR  (10)   NOT NULL DEFAULT (''),           --是否虚件
    [SCHGT]              VARCHAR  (10)   NOT NULL DEFAULT (''),           --是否散装
    [RGEKZ]              VARCHAR  (10)   NOT NULL DEFAULT (''),           --是否反冲
    [WERKS]              VARCHAR  (10)   NOT NULL DEFAULT (''),           --工厂
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间(MES导入时间)
    [MesCreateUser]      NVARCHAR (50)   NOT NULL DEFAULT (N'SAP'),       --创建用户
    [MesModifyTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [MesModifyUser]      NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [MesStatus]          INT             NOT NULL DEFAULT (0)             --订单状态: 0:待生产, 1:产前调整中, 2:生产进行中, 3:已完成
);

--参考的ERP库存信息数据表
IF OBJECT_ID('ERP_Inventory_List') is not null
DROP TABLE ERP_Inventory_List;
CREATE TABLE [dbo].[ERP_Inventory_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [SOURCEID]           INT             NOT NULL DEFAULT (0) ,           --源表ID
    [MATNR]              VARCHAR  (50)   NOT NULL,                        --原料编码
    [MAKTX]              NVARCHAR (50)   NOT NULL,                        --原料描述
    [INVQTY]             NUMERIC  (18, 4)    NULL,                        --库存数量
    [ErpUpdateTime]      DATETIME            NULL,                        --ERP获取时间 (如果不为空, 则说明需要ERP接口程序需要获得数据)
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE()       --Mes创建时间
);

--参考的ERP库存信息数据表日志表
IF OBJECT_ID('Log_ERP_Inventory_List') is not null
DROP TABLE Log_ERP_Inventory_List;
CREATE TABLE [dbo].[Log_ERP_Inventory_List] (
    [ID]                 INT             NOT NULL,                    -- (系统自动生成)
    [SOURCEID]           INT             NOT NULL DEFAULT (0) ,           --源表ID
    [MATNR]              VARCHAR  (50)   NOT NULL,                        --原料编码
    [MAKTX]              NVARCHAR (50)   NOT NULL,                        --原料描述
    [INVQTY]             NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --库存数量
    [ErpUpdateTime]      DATETIME            NULL,                        --ERP获取时间 (如果不为空, 则说明需要ERP接口程序需要获得数据)
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE()       --Mes创建时间
);



-- --ERP库房库存表, 此表不用了(选择了上面的那个少字段的表)
-- IF OBJECT_ID('ERP_INV_List') is not null
-- DROP TABLE ERP_INV_List;
-- CREATE TABLE [dbo].[ERP_INV_List] (
--     [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
--     [LineNumber]         INT             NOT NULL DEFAULT (0),            --行号
--     [WHCode]             VARCHAR  (50)   NOT NULL DEFAULT (N''),          --库房编号
--     [WHLocation]         VARCHAR  (50)   NOT NULL DEFAULT (N''),          --库位
--     [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
--     [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
--     [Qty]                NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --用量
--     [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'个'),        --用料计量单位
--     [InventoryTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --物料时间(入库)
--     [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间(MES导入时间)
--     [MesCreateUser]      NVARCHAR (50)   NOT NULL,                        --创建用户
--     [MesModifyTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
--     [MesModifyUser]      NVARCHAR (50)   NOT NULL,                        --更新用户
--     [MesStatus]          INT             NOT NULL DEFAULT (0)             --订单状态: 0:待生产, 1:产前调整中, 2:生产进行中, 3:已完成
-- );

--产线的生产工单
IF OBJECT_ID('MFG_WO_List') is not null
DROP TABLE MFG_WO_List;
CREATE TABLE [dbo].[MFG_WO_List] (
    [ID]                INT IDENTITY (1, 1) NOT NULL,                     -- (系统自动生成)
    [ErpWorkOrderNumber]    VARCHAR  (50)   NOT NULL,                     --订单编号
    [ErpGoodsCode]          VARCHAR  (50)   NOT NULL,                     --产品的物料编码
    [ErpGoodsDsca]          NVARCHAR (50)   NOT NULL,                     --产品的物料描述
    [ErpPlanQty]            INT             NOT NULL DEFAULT (0),         --计划产量
    [ErpPlanCreateTime]     DATETIME        NOT NULL,                     --计划创建时间
    [ErpPlanStartTime]      DATETIME        NOT NULL,                     --计划开始时间
    [ErpPlanFinishTime]     DATETIME        NOT NULL,                     --计划完成时间
    [ErpPlanReleaseTime]    DATETIME        NOT NULL,                     --计划发行时间
    [ErpWorkGroup]          VARCHAR  (15)   NOT NULL DEFAULT ('LNRT01'),  --生产线编号
    [ErpOrderType]          VARCHAR  (10)   NOT NULL DEFAULT (''),        --ERP订单类型
    [ErpOrderStatus]        VARCHAR  (50)   NOT NULL DEFAULT (''),        --ERP订单状态
    [ErpOBJNR]              VARCHAR  (30)   NOT NULL DEFAULT (''),        --对象号
    [ErpZTYPE]              VARCHAR  (30)   NOT NULL DEFAULT (''),        --订单类别
    [MesInturnNumber]       INT             NOT NULL DEFAULT (0),         --生产排程顺序号(以这个顺序号来决定工单的排产顺序, 不以计划开始时间为准.)
    [MesWorkOrderType]      INT             NOT NULL DEFAULT (0),         --订单类型: 0:正常订单; 1:下线补单(未完,补修,报废)
    [MesWorkOrderVersion]   INT             NOT NULL DEFAULT (0),         --订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [MesActualStartTime]    DATETIME            NULL,                     --实际开始时间
    [MesActualFinishTime]   DATETIME            NULL,                     --实际完成时间
    [MesPlanQty]            INT             NOT NULL DEFAULT (0),         --计划产量
    [MesFinishQty]          INT             NOT NULL DEFAULT (0),         --已经完成产量
    [MesDiscardQty1]        INT             NOT NULL DEFAULT (0),         --下线数量:下线工位1报废计数
    [MesDiscardQty2]        INT             NOT NULL DEFAULT (0),         --下线数量:下线工位2报废计数
    [MesDiscardQty3]        INT             NOT NULL DEFAULT (0),         --下线数量:下线工位3报废计数
    [MesDiscardQty4]        INT             NOT NULL DEFAULT (0),         --下线数量:下线工位4报废计数
    [MesLeftQty1]           INT             NOT NULL DEFAULT (0),         --下线数量:下线工位1未完工数量, 只统计本工位"未完工"下线的值 
    [MesLeftQty2]           INT             NOT NULL DEFAULT (0),         --下线数量:下线工位2未完工数量, 只统计本工位"未完工"下线的值  
    [MesLeftQty3]           INT             NOT NULL DEFAULT (0),         --下线数量:下线工位3未完工数量, 只统计本工位"未完工"下线的值  
    [MesLeftQty4]           INT             NOT NULL DEFAULT (0),         --下线数量:下线工位4未完工数量, 只统计本工位"未完工"下线的值  
    [MesCreateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),   --创建时间(或MES导入时间)
    [MesCreateUser]         NVARCHAR (50)   NOT NULL DEFAULT ('MES_SYS'), --创建用户
    [MesModifyTime]         DATETIME        NOT NULL DEFAULT GETDATE(),   --更新时间
    [MesModifyUser]         NVARCHAR (50)       NULL,                     --更新用户
    [MesStatus]             INT             NOT NULL DEFAULT (0),         --MES状态: 0:待生产, 1:产前调整中, 2:生产进行中, 3:已完成
    [MesPlanStartTime]      DATETIME            NULL,                     --计划开始时间
    [MesPlanFinishTime]     DATETIME            NULL,                     --计划完成时间
    [MesCostTime]           INT                 NULL DEFAULT (0),         --预计生产耗时(分钟)
    [MesUnitCostTime]       INT                 NULL DEFAULT (2),         --单位生产耗时(分钟)
    [MesCustomerID]         INT                 NULL,                     --客户ID
    [MesCodeUbound]         INT             NOT NULL DEFAULT (0),         --MesCode流水号的边界值, 用以记录生成了多少MESCode标签值
    [MesOrderComment]       NVARCHAR(150)       NULL,                     --订单说明
    [Mes2ErpMVTStatus]      INT             NOT NULL DEFAULT (-1),        --订单发料状态: -1:新增, 0:待处理, 1:进行中, 2:失败, 3:已完成 [ZME_GOODSMVT_CREATE]         
    [Mes2ErpCfmStatus]      INT             NOT NULL DEFAULT (-1),        --订单报工状态: -1:新增, 0:待处理, 1:进行中, 2:失败, 3:已完成 [BAPI_PRODORDCONF_CREATE_HDR] 
    [Mes2ErpMVTQty]         INT             NOT NULL DEFAULT (0),         --订单发料数量: [ZME_GOODSMVT_CREATE]          --此字段目前用不上, 因为SAP处理时不需要数量作为参数.
    [Mes2ErpCfmQty]         INT             NOT NULL DEFAULT (0),         --订单报工数量: [BAPI_PRODORDCONF_CREATE_HDR]  
    [MesStartPoint]         VARCHAR  (50)   NOT NULL DEFAULT ('0'),       --订单上线工序点(正常订单或者补单如果有报废, 则首道工序, 其它下线则以低工序下线点为准.)
    [MesSubPlanFlag]        INT             NOT NULL DEFAULT (0)          --已经创建下线补单标志: 0: 未创建; 1: 已经创建          
);

--产线的生产工单用料表
IF OBJECT_ID('MFG_WO_MTL_List') is not null
DROP TABLE MFG_WO_MTL_List;
CREATE TABLE [dbo].[MFG_WO_MTL_List] (
    [ID]             INT IDENTITY (1, 1) NOT NULL,                        -- (系统自动生成)
    [CommentReqNumber]   NUMERIC  (10,0)     NULL,                        --预留(需求编号)
    [CommentReqPosition] INT                 NULL,                        --预留(项目编号)
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL,                        --订单编码
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (0),            --订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [LineNumber]         INT             NOT NULL,                        --行号(BOM项目号)
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
    [LeftQty]            NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --剩余数量
    [Qty]                NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --需求数量
    [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'个'),        --用料计量单位
    [ProcessCode]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序编号
    [WorkCenter]         VARCHAR  (50)   NOT NULL DEFAULT (N''),          --工作中心
    [WcDsca]             NVARCHAR (50)   NOT NULL DEFAULT (N''),          --短描述 (工作中心短描述)
    [WHLocation]         VARCHAR  (50)   NOT NULL DEFAULT (N''),          --库位
    [Phantom]            VARCHAR  (10)   NOT NULL DEFAULT (''),           --是否虚件
    [Bulk]               VARCHAR  (10)   NOT NULL DEFAULT (''),           --是否散装
    [Backflush]          VARCHAR  (10)   NOT NULL DEFAULT (''),           --是否反冲
    [WorkSite]           VARCHAR  (10)   NOT NULL DEFAULT (''),           --工厂
    [MesCreateTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间
    [MesCreateUser]      NVARCHAR (50)   NOT NULL,                        --创建用户
    [MesModifyTime]      DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [MesModifyUser]      NVARCHAR (50)   NOT NULL,                        --更新用户
    [MesStatus]          INT             NOT NULL DEFAULT (0)             --用料状态: 0:新增, 1:正常, -1:修改, -2: 删除
);

--产线的物料拉动表
IF OBJECT_ID('MFG_WO_MTL_Pull') is not null
DROP TABLE MFG_WO_MTL_Pull;
CREATE TABLE [dbo].[MFG_WO_MTL_Pull] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL,                        --订单编码
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (0),            --订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [NextWorkOrderNumber] VARCHAR  (50)  NOT NULL DEFAULT (''),           --下一订单编码
    [NextWorkOrderVersion]INT            NOT NULL DEFAULT (0),            --下一订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [NextWOPlanQty]      INT             NOT NULL DEFAULT (0),            --下一工单的计划产量
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
    [ActionTotalQty]     NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --当前工单已经响应的数量(和)
    [Qty]                NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --用量
    [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'个'),        --用料计量单位
    [ProcessCode]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序编号
    [PullTime]           DATETIME        NOT NULL DEFAULT GETDATE(),      --拉动时间
    [PullUser]           NVARCHAR (50)   NOT NULL,                        --拉动用户
    [ActionQty]          NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --响应用量(实发数量)
    [ActionTime]         DATETIME            NULL,                        --响应时间
    [ActionUser]         NVARCHAR (50)       NULL,                        --响应用户
    [ConfirmTime]        DATETIME            NULL,                        --确认时间
    [ConfirmUser]        NVARCHAR (50)       NULL,                        --确认用户
    [OTFlag]             INT             NOT NULL DEFAULT (0),            --是否超时: 0:未超时; 1:超时
    [Status]             INT             NOT NULL DEFAULT (0)             --状态: -2:删除(拒绝); 0:待响应; 1:待确认; 2:已完成
);

--产线的物料拉动附属物料表, 用以解决一点触发会同时拉动多种物料的情况(依据比例进行套料发送)
IF OBJECT_ID('Mes_Mtl_Pull_Item_Attached') is not null
DROP TABLE Mes_Mtl_Pull_Item_Attached;
CREATE TABLE [dbo].[Mes_Mtl_Pull_Item_Attached] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [GoodsCode]          VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [MainItem]           VARCHAR  (50)   NOT NULL,                        --原料编码-主料
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码-附属
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
    [RatioQty]           NUMERIC  (18, 4)NOT NULL DEFAULT (1)             --用料比例; 主料用量:附属料用量 = 1:RatioQty
);

--产线的反冲物料料号清单
IF OBJECT_ID('MFG_WIP_BKF_Item_List') is not null
DROP TABLE MFG_WIP_BKF_Item_List;
CREATE TABLE [dbo].[MFG_WIP_BKF_Item_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --物料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --物料描述
    [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'EA'),        --用料计量单位
    [CreateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --创建时间
    [CreateUser]         NVARCHAR (50)   NOT NULL,                        --创建用户
    [ModifyTime]         DATETIME            NULL,                        --更新时间
    [ModifyUser]         NVARCHAR (50)       NULL,                        --更新用户
    [Status]             INT             NOT NULL DEFAULT (0)             --状态: 0:新增, -1:修改, -2:删除
);

--产线的反冲物料拉动记录表
IF OBJECT_ID('MFG_WIP_BKF_MTL_Record') is not null
DROP TABLE MFG_WIP_BKF_MTL_Record;
CREATE TABLE [dbo].[MFG_WIP_BKF_MTL_Record] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --物料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --物料描述
    [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'EA'),        --计量单位
    [ApplyTime]          DATETIME        NOT NULL DEFAULT GETDATE(),      --申请时间
    [ApplyUser]          NVARCHAR (50)   NOT NULL,                        --申请用户
    [ApplyQty]           NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --申请数量
    [ActionTime]         DATETIME            NULL,                        --响应时间
    [ActionUser]         NVARCHAR (50)       NULL,                        --响应用户
    [ActionQty]          NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --响应数量
    [ConfirmTime]        DATETIME            NULL,                        --确认时间
    [ConfirmUser]        NVARCHAR (50)       NULL,                        --确认用户
    [ConfirmQty]         NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --确认数量
    [OTFlag]             INT             NOT NULL DEFAULT (0),            --是否超时: 0:未超时; 1:超时
    [Status]             INT             NOT NULL DEFAULT (0)             --状态: 0:待响应; 1:待确认; 2:已完成
);

--产线下线工序类型表
IF OBJECT_ID('MFG_WIP_Data_Abnormal_Point') is not null
DROP TABLE MFG_WIP_Data_Abnormal_Point;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_Point] (
    [ID]                 INT             NOT NULL,                        --非系统生成
    [ProcessCode]        NVARCHAR  (50)  NOT NULL DEFAULT (N''),          --工序编号
    [DisplayValue]       NVARCHAR  (50)  NOT NULL                         --显示内容
);

INSERT INTO MFG_WIP_Data_Abnormal_Point (ID, ProcessCode, DisplayValue)
VALUES
(1, N'1060', N'铜排气密性检测'),
(2, N'1090', N'板芯气密性检测'),
(3, N'2100', N'板芯装配'),
(4, N'3030', N'终检(预装压条)');


--产线下线产品阶段表
IF OBJECT_ID('MFG_WIP_Data_Abnormal_Product') is not null
DROP TABLE MFG_WIP_Data_Abnormal_Product;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_Product] (
    [ID]                 INT             NOT NULL,                        --非系统生成
    [DisplayValue]       NVARCHAR  (50)  NOT NULL                         --显示内容
);

INSERT INTO MFG_WIP_Data_Abnormal_Product (ID, DisplayValue)
VALUES
(1, N'铜排'),
(2, N'板芯'),
(3, N'外框'),
(4, N'半成品'),
(5, N'成品(终检)');


--产线下线工序、产品阶段许可表
IF OBJECT_ID('MFG_WIP_Data_Abnormal_Point_Product') is not null
DROP TABLE MFG_WIP_Data_Abnormal_Point_Product;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_Point_Product] (
    [abPointID]          INT             NOT NULL,                        --下线工序ID
    [abProductID]        INT             NOT NULL                         --下线产品阶段ID
);

INSERT INTO MFG_WIP_Data_Abnormal_Point_Product (abPointID, abProductID)
VALUES
(1, 1),
(2, 2),
(3, 2),
(3, 3),
(3, 4),
(4, 5);

--产线下线产品原因模板表
IF OBJECT_ID('MFG_WIP_Data_Abnormal_Reason_Template') is not null
DROP TABLE MFG_WIP_Data_Abnormal_Reason_Template;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_Reason_Template] (
    [ID]                 INT             NOT NULL,                        --非系统生成
    [abProductID]        INT             NOT NULL DEFAULT(0),             --下线产品阶段ID
    [DisplayValue]       VARCHAR  (50)   NOT NULL                         --显示内容
);

INSERT INTO MFG_WIP_Data_Abnormal_Reason_Template (ID, abProductID, DisplayValue)
VALUES
(101, 1, N'黄铜接头'),
(102, 1, N'缩口焊接'),
(103, 1, N'集管折弯'),
(104, 1, N'焊点(集管排管)'),
(199, 1, N'其它'),

(201, 2, N'黄铜接头'),
(202, 2, N'缩口焊接'),
(203, 2, N'集管折弯'),
(204, 2, N'焊点(集管排管)'),
(205, 2, N'吸热板焊穿'),
(206, 2, N'排管焊穿'),
(207, 2, N'吸热板划伤、碰伤'),
(299, 2, N'其它'),

(301, 3, N'型材划伤、硌伤'),
(302, 3, N'背板折伤'),
(303, 3, N'四角硌伤'),
(304, 3, N'四角间隙过大'),
(305, 3, N'边框装错'),
(399, 3, N'其它'),

(401, 4, N'吸热板划伤、碰伤'),
(402, 4, N'黄铜接头断裂'),
(499, 4, N'其它'),

(501, 5, N'涂胶断续'),
(502, 5, N'玻璃划伤'),
(503, 5, N'玻璃掉落'),
(504, 5, N'玻璃碎裂'),
(505, 5, N'压条报废'),
(506, 5, N'边框四角间隙过大'),
(599, 5, N'其它');

--产线下线时需要计算的Process清单(这里面暗含一个路由的概念, 可以定义工序分支的情形)
IF OBJECT_ID('MFG_WIP_Data_Abnormal_Process') is not null
DROP TABLE MFG_WIP_Data_Abnormal_Process;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_Process] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [abPointID]          INT                 NULL,                        --下线工序ID, 亦即下线点: AbnormalPoint
    [abProductID]        INT                 NULL,                        --下线产品阶段ID
    [ProcessCode]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序编号
    [ParaType]           INT             NOT NULL DEFAULT (0),            --0:下线时已经耗料的Process;
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --状态: 0:新增, -1:修改, -2:删除;
);

INSERT INTO MFG_WIP_Data_Abnormal_Process (abProductId, ProcessCode) 
VALUES
(1, '1010'),(1, '1020'),(1, '1030'),(1, '1040'),(1, '1050'),(1, '1060'), --铜排
(2, '1010'),(2, '1020'),(2, '1030'),(2, '1040'),(2, '1050'),(2, '1060'),(2, '1070'),(2, '1080'),(2, '1090'), --板芯
(3, '2010'),(3, '2020'),(3, '2030'),(3, '2040'),(3, '2050'),(3, '2060'),(3, '2070'),(3, '2080'),(3, '2090'),(3, '2100'); --外框

INSERT INTO MFG_WIP_Data_Abnormal_Process (abProductId, ProcessCode) 
SELECT 4, ProcessCode
FROM MFG_WIP_Data_Abnormal_Process 
WHERE abProductId = 2 -- OR abProductId = 3     --半成品 (=板芯), 原来把外框也计算在内了, 后来发现半成品原因不包含外框项目, 因此去除.


INSERT INTO MFG_WIP_Data_Abnormal_Process (abProductId, ProcessCode) 
SELECT 5, ProcessCode
FROM MFG_WIP_Data_Abnormal_Process 
WHERE abProductId = 2 OR abProductId = 3     --成品(终检) (板芯 + 外框 + 3个额外工序)

INSERT INTO MFG_WIP_Data_Abnormal_Process (abProductId, ProcessCode) 
VALUES
(5, '3010'),
(5, '3020'),
(5, '3030');


--产线下线数据记录表, 每一个RFID对应一个条下线记录(相同RFID可能会有多条记录, 因为可能存在重复下线的可能)
IF OBJECT_ID('MFG_WIP_Data_Abnormal') is not null
DROP TABLE MFG_WIP_Data_Abnormal;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [RFID]               NVARCHAR (50)   NOT NULL DEFAULT (N''),          --RFID值
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL,                        --订单编码
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (0),            --订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [AbnormalPoint]      INT             NOT NULL DEFAULT (3),            --下线点编号: 只允许指定的四个下线工序: 1.铜排气密性检测;2.板芯气密性检测;3.板芯装配;4:终检(预装压条)
    [AbnormalProduct]    INT             NOT NULL DEFAULT (0),            --下线产品阶段
    [AbnormalType]       INT             NOT NULL DEFAULT (1),            --下线类型: 1:补修; 2:报废; 3:未完工
    [AbnormalTime]       DATETIME        NOT NULL DEFAULT GETDATE(),      --下线时间
    [AbnormalUser]       NVARCHAR (50)   NOT NULL,                        --下线用户
    [AbnormalReason]     NVARCHAR (200)  NOT NULL,                        --下线原因, 此字段目前不会被使用到了, 因为项目需求发生巨大变化.
    [SubPlanStatus]      INT             NOT NULL DEFAULT (0),            --创建下线补单状态: 0:未创建; 1:已创建;
    [RepairStatus]       INT             NOT NULL DEFAULT (0),            --补修状态: 0:待补修; 1:补修中; 2:已完成;
    [RepairTime]         DATETIME            NULL,                        --补修时间
    [RepairUser]         NVARCHAR (50)       NULL,                        --补修用户
    [RepairComment]      NVARCHAR (200)      NULL,                        --补修说明
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL                         --更新用户
);

--产线下线产品原因记录表
IF OBJECT_ID('MFG_WIP_Data_Abnormal_Reason') is not null
DROP TABLE MFG_WIP_Data_Abnormal_Reason;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_Reason] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [AbnormalID]         INT             NOT NULL DEFAULT (0),            --MFG_WIP_Data_Abnormal表的ID
    [TemplateID]         INT             NOT NULL,                        --下线产品阶段ID
    [RecordValue]        INT             NOT NULL DEFAULT(0)              --出现产品下线原因数量
);

--产线下线物料数据维护表, 每一种物料对应一条记录
IF OBJECT_ID('MFG_WIP_Data_Abnormal_MTL') is not null
DROP TABLE MFG_WIP_Data_Abnormal_MTL;
CREATE TABLE [dbo].[MFG_WIP_Data_Abnormal_MTL] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [AbnormalID]         INT             NOT NULL DEFAULT (0),            --MFG_WIP_Data_Abnormal表的ID
    [ProcessCode]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序编号
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
    [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'个'),        --用料计量单位
    [LeftQty]            NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --剩余数量
    [RequireQty]         NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --需求数量
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL                         --更新用户
);


--产线生产数据记录表RFID, 每过一个RFID位置, 即新增一条记录
IF OBJECT_ID('MFG_WIP_Data_RFID') is not null
DROP TABLE MFG_WIP_Data_RFID;
CREATE TABLE [dbo].[MFG_WIP_Data_RFID] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL DEFAULT (N'') ,         --订单编码
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (0),            --订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [RFID]               NVARCHAR (50)   NOT NULL DEFAULT (N''),          --RFID值
    [ItemNumber]         VARCHAR  (50)       NULL,                        --原料编码
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL,                        --更新用户
    [Status]             INT             NOT NULL DEFAULT (0)             --状态: 0:正常; 1:补修; 2:报废; 3:未完工
);

--产线生产数据记录表OPC_PLC
IF OBJECT_ID('MFG_WIP_Data_PLC') is not null
DROP TABLE MFG_WIP_Data_PLC;
CREATE TABLE [dbo].[MFG_WIP_Data_PLC] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL DEFAULT (N'') ,         --订单编码
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (0),            --订单版本: 目的是为了区分开来补单的补单, 0:正常订单; >0: 其余补单顺次+1
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [PLCCode]            NVARCHAR (50)   NOT NULL DEFAULT (N''),          --PLC编号
    [ItemNumber]         VARCHAR  (50)       NULL,                        --原料编码
    [Qty]                NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --PLC计数用量
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT ('MES_SYS'),    --更新用户: MES_SYS
    [Status]             INT             NOT NULL DEFAULT (0)             --状态: 0:新增; 1:生产中; 2:已完成
);

--MES全局配置表
--此表设计初衷是只保留一条记录, 
--每个字段代表一项配置参数用以对系统进行配置.
IF OBJECT_ID('Mes_Config') is not null
DROP TABLE Mes_Config;
CREATE TABLE [dbo].[Mes_Config] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [PlayPause]             VARCHAR(20)     NOT NULL DEFAULT ('PLAY'),       --此值代表系统当前状态, 不是代表界面的提示字
    [ERP_ORDER_DETAIL]      VARCHAR(20)     NOT NULL DEFAULT ('0'),          --0: 暂停刷新; 1: 等待刷新; 2: 响应刷新; 3: 刷新成功: 4: 刷新失败
    [ERP_GOODSMVT_CREATE]   VARCHAR(20)     NOT NULL DEFAULT ('0'),          --0: 暂停刷新; 1: 等待发料; 2: 响应刷新; 3: 刷新成功: 4: 刷新失败
    [ERP_ORDER_CONFIRM]     VARCHAR(20)     NOT NULL DEFAULT ('0'),          --0: 暂停刷新; 1: 等待报工; 2: 响应刷新; 3: 刷新成功: 4: 刷新失败
    [ERP_INVENTORY_DATA]    VARCHAR(20)     NOT NULL DEFAULT ('0')           --0: 暂停刷新; 1: 等待库存; 2: 响应刷新; 3: 刷新成功: 4: 刷新失败
 -- [RefreshERPWO]          VARCHAR(20)     NOT NULL DEFAULT ('0'),          --此参数已经不用, 是接口没有定义完成之前开发期间使用的标记字, 当下数据库中也不存在了. 0: 暂停刷新; 1: 刷新SAP生产订单;       2: 响应刷新; 3: 刷新成功: 4: 刷新失败
 -- [ConfirmERPWO]          VARCHAR(20)     NOT NULL DEFAULT ('0')           --此参数已经不用, 是接口没有定义完成之前开发期间使用的标记字, 当下数据库中也不存在了. 1: 确认订单; 0: 未确认 (其0值和RefreshERPWO互斥,目的是排程界面的使能控制)
);

--能源历史记录表
--此表设计用意是记录工厂的电能用量(包含示数)历史
IF OBJECT_ID('Mes_Energy_Record') is not null
DROP TABLE Mes_Energy_Record;
CREATE TABLE [dbo].[Mes_Energy_Record] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [DisplayValue]       INT             NOT NULL DEFAULT ('0'),          --电表市数
    [CostValue]          INT             NOT NULL DEFAULT ('0')           --最近时间间隔内电能消耗值
);

--工位生产用时(节拍:秒)记录表
--此表设计用意是记录工位记录的产出数据时的时刻间隔
--此表只记录有PLC产量计数工位的数据.
IF OBJECT_ID('Mes_Process_Beat_Record') is not null
DROP TABLE Mes_Process_Beat_Record;
CREATE TABLE [dbo].[Mes_Process_Beat_Record] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [UpdateTime]       DATETIME        NOT NULL DEFAULT GETDATE(),        --更新时间
    [ProcessCode]      VARCHAR  (50)   NOT NULL DEFAULT (''),             --工序编号
    [WorkOrderNumber]  VARCHAR  (50)   NOT NULL DEFAULT (N''),            --订单编码-用以记录工位计数值记录值:当前正在进行生产的数据
    [WorkOrderVersion] INT             NOT NULL DEFAULT (-1),             --订单版本-用以记录工位计数值记录值:当前正在进行生产的数据
    [TagName]          VARCHAR  (50)   NOT NULL,                          --PLC参数名称
    [DisplayValue]     INT             NOT NULL,                          --PLC参数数值: 产量示数
    [BeatValue]        INT             NOT NULL DEFAULT ('0')             --最近时间间隔值(Beat值:秒)
);

--客户信息表
IF OBJECT_ID('Mes_Customer_List') is not null
DROP TABLE Mes_Customer_List;
CREATE TABLE [dbo].[Mes_Customer_List] (
    [CustomerID]         INT IDENTITY (1, 1) NOT NULL,                  -- (系统自动生成)
    [CustomerName]           NVARCHAR (50)   NOT NULL DEFAULT (N''),      --客户名称
    [CustomerLogo]           NVARCHAR (50)   NOT NULL DEFAULT (N'')       --客户上传Logo的文件名称
);

INSERT INTO Mes_Customer_List (CustomerName, CustomerLogo)
VALUES 
('万科地产', 'wk.png'),
('鲁能地产', 'ln.png');

--生产线线别信息表
IF OBJECT_ID('Mes_Line_List') is not null
DROP TABLE Mes_Line_List;
CREATE TABLE [dbo].[Mes_Line_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [LineCode]           VARCHAR  (15)   NOT NULL DEFAULT ('LNRT01'),     --生产线编号
    [LineName]           NVARCHAR (50)   NOT NULL DEFAULT (N''),          --生产线名称
    [LineDsca]           NVARCHAR (500)  NOT NULL DEFAULT (N''),          --生产线简介
    [LineCapacity]       INT             NOT NULL DEFAULT (240),          --设计产能
    [LineHeadCount]      INT             NOT NULL DEFAULT (11),           --产线配员
    [ShiftHours]         INT             NOT NULL DEFAULT (8),            --每日工时(小时)
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N'')           --更新用户
);

--工序信息表 (建议加入PLC_Code)
IF OBJECT_ID('Mes_Process_List') is not null
DROP TABLE Mes_Process_List;
CREATE TABLE [dbo].[Mes_Process_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [InturnNumber]       INT             NOT NULL DEFAULT (0),            --工序顺序号(以这个顺序号来决定排产顺序) 1xxx:板芯; 2xxx:边框; 3xxx:合并; 6xxx:Customerize
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [ProcessName]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序名称
    [ProcessDsca]        NVARCHAR (500)  NOT NULL DEFAULT (N''),          --生工序简介
    [ProcessBeat]        INT             NOT NULL DEFAULT (120),          --工序节拍(秒)
    [ProcessManual]      NVARCHAR (100)  NOT NULL DEFAULT (N''),          --操作规范
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [Status]             INT             NOT NULL DEFAULT (0),            --订单状态: 0:新增, -1:修改, -2:删除
    [ReservedFlag]       INT             NOT NULL DEFAULT (0),            --本记录是否预定义标记: 0: 否; 1: 是 (本字段是为了保证实施后,保留工序是否可以被删除和工序顺序号是否可以被修改)
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL DEFAULT (N''),          --订单编码-用以记录工位计数值记录值:当前正在进行生产的数据
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (-1),           --订单版本-用以记录工位计数值记录值:当前正在进行生产的数据
    [NextWorkOrderNumber] VARCHAR  (50)  NOT NULL DEFAULT (N''),          --订单编码-用以记录工位计数值记录值:下一订单即将进行生产的数据,等待产线把请求改产信号切换时, 即把此值覆盖当前正在生产之值
    [NextWorkOrderVersion]INT            NOT NULL DEFAULT (-1),           --订单版本-用以记录工位计数值记录值:下一订单即将进行生产的数据,等待产线把请求改产信号切换时, 即把此值覆盖当前正在生产之值
    [FinishQty]          INT             NOT NULL DEFAULT (-1),           --本工序的已经完成产量: -1: 代表当前工单已经结单
    [PlanQty]            INT             NOT NULL DEFAULT (0),            --本工序的计划产量: 此数值是在PLC参数派发的过程中自己保留一份, 用以决定本工序是否完成的判断依据.
    [ParamTime]          DATETIME        NOT NULL DEFAULT GETDATE(),      --PLC触发时间
    [ParamName]          VARCHAR  (50)   NOT NULL DEFAULT (''),           --PLC参数名称: OPC Tag值
    [ParamValue]         VARCHAR  (50)   NOT NULL DEFAULT (''),           --PLC参数数值
    [AbnormalRegion]     INT             NOT NULL DEFAULT (3),            --所属的下线区的下线点编号
    [AbnormalEnable]     INT             NOT NULL DEFAULT (0),            --允许下线点标志: 0: 不允许; 1: 允许
    [FinalFlag]          INT             NOT NULL DEFAULT (0),            --工序结单标志(即:本工序如果数量满足要求, 则要结束订单动作): 0: 否; 1: 是
    [StartFlag]          INT             NOT NULL DEFAULT (0)             --工序首序标志(即:本工序是否是第一个工序, 则要改变工单状态): 0: 否; 1: 是

);

--产品用料分布
IF OBJECT_ID('Mes_Mub_List') is not null
DROP TABLE Mes_Mub_List;
CREATE TABLE [dbo].[Mes_Mub_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [GoodsCode]          VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [ProcessName]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序名称
    [MubPercent]         NUMERIC  (18, 4)NOT NULL DEFAULT (100),          --PLC计数用量
    [UploadUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UploadTime]         DATETIME        NOT NULL DEFAULT GETDATE()       --上传时间
)

--产品用料分布(文件上传临时用)
IF OBJECT_ID('Mes_Mub_List_UP') is not null
DROP TABLE Mes_Mub_List_UP;
CREATE TABLE [dbo].[Mes_Mub_List_UP] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [TargetFileName]     NVARCHAR (50)   NOT NULL DEFAULT (N'') ,         --文件上传之后在服务器上保留的文件名称 
    [GoodsCode]          VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
    [ItemDsca]           NVARCHAR (50)   NOT NULL,                        --原料描述
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [ProcessName]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --工序名称
    [MubPercent]         NUMERIC  (18, 4)NOT NULL DEFAULT (100),          --PLC计数用量
    [UploadUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UploadTime]         DATETIME        NOT NULL DEFAULT GETDATE()       --上传时间
)


--物料编码表 (注意: 此处没有PLC_Code, 需要和Mes_PLC_List进行笛卡尔积计算得来PLC的配置.)
IF OBJECT_ID('Mes_Goods_List') is not null
DROP TABLE Mes_Goods_List;
CREATE TABLE [dbo].[Mes_Goods_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [GoodsCode]          VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [GoodsDsca]          NVARCHAR (50)   NOT NULL,                        --产品的物料描述
    [DimLength]          INT             NOT NULL DEFAULT (120),          --长度(mm)
    [DimHeight]          INT             NOT NULL DEFAULT (120),          --高端(mm)
    [DimWidth]           INT             NOT NULL DEFAULT (120),          --宽度(mm)
    [UnitCostTime]       INT             NOT NULL DEFAULT (2),            --单位生产耗时(分钟)
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);


--PLC信息表
IF OBJECT_ID('Mes_PLC_List') is not null
DROP TABLE Mes_PLC_List;
CREATE TABLE [dbo].[Mes_PLC_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [GoodsCode]          VARCHAR  (50)   NOT NULL,                        --产品的物料编码
    [PLCCode]            VARCHAR  (50)   NOT NULL,                        --PLC编码(CP01)
    [PLCName]            NVARCHAR (50)   NOT NULL,                        --PLC名称(底板上料直角坐标)
    [PLCType]            NVARCHAR (50)   NOT NULL,                        --PLC设备类型(西门子, 施耐德, ...)
    [PLCModel]           NVARCHAR (50)   NOT NULL,                        --PLC设备型号(SMART200 ST30,TM241CEC24R, ...)
    [PLCCabinet]         NVARCHAR (50)   NOT NULL,                        --PLC柜号(LN01, LN02,...)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号(作为在进行 参数派发 操作的时候,可以预选的过滤条件 )
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [DownloadTime]       DATETIME        NOT NULL DEFAULT GETDATE(),      --派发时间
    [FeedBackTime]       DATETIME        NOT NULL DEFAULT GETDATE(),      --回馈时间(派发完成时间)
    [DownloadFlag]       INT             NOT NULL DEFAULT (0),            --派发标志: 0:静止待命, 2:等待派发, 4:派发开始, 6: 等待回馈, 8: 回馈成功, -2:回馈失败
    [Status]             INT             NOT NULL DEFAULT (0)             --设备状态: 0:新增, -1:修改, -2:删除
);

--PLC信息参数配置表
--如果有需要拉动的物料, 针对具体产品需要对此记录进行编辑(设定料号和放置位置号)
IF OBJECT_ID('Mes_PLC_Parameters') is not null
DROP TABLE Mes_PLC_Parameters;
CREATE TABLE [dbo].[Mes_PLC_Parameters] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [PLCID]              INT             NOT NULL,                        --PLCID
    [ParamName]          VARCHAR  (50)   NOT NULL,                        --PLC参数名称: OPC Tag值
    [ParamDsca]          NVARCHAR (50)   NOT NULL,                        --PLC参数描述
    [ParamValue]         VARCHAR  (50)   NOT NULL,                        --PLC参数数值
    [ParamType]          VARCHAR  (10)   NOT NULL,                        --PLC参数类型: (BYTE, DWORD, BOOL, ...)
    [OperateType]        VARCHAR  (10)   NOT NULL,                        --操作类型: R:读取; W:写入; RW:读写; C:计数
    [OperateCommand]     VARCHAR  (10)   NOT NULL,                        --操作命令: RESET:重置; WRITE:写入; READ:读取; IGNORE:忽略(不做任何操作)
    [ApplModel]          VARCHAR  (10)       NULL,                        --应用模块: 参照字段值 Mes_PLC_ApplModel_List->ApplModel
    [ApplData]           NVARCHAR (50)       NULL,                        --应用模块属性值: 如报警模块的提示字: "压力报警25MPa"中的25字样等, 其"压力报警"字样可以取自ParaDsca, 物料拉动时物料放置位置编号(为了大屏显示之用)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号(作为在进行 物料拉动 的时候, 可以通过此参数最终获取到对应的工单{尽管有时需要逻辑计算才可能获得生产排程决定的下一个新启动的工单} )
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码 (备用, 用以标记某个PLC的参数单独和某种原料进行设定.)
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [WorkOrderNumber]    VARCHAR  (50)   NOT NULL DEFAULT (N''),          --订单编码-用以物料拉动之记录值
    [WorkOrderVersion]   INT             NOT NULL DEFAULT (-1),           --订单版本-用以物料拉动之记录值
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--PLC信息参数配置表上传时候的临时存储表
IF OBJECT_ID('Mes_PLC_Parameters_UP') is not null
DROP TABLE Mes_PLC_Parameters_UP;
CREATE TABLE [dbo].Mes_PLC_Parameters_UP (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [TargetFileName]     NVARCHAR (50)   NOT NULL DEFAULT (N'') ,         --文件上传之后在服务器上保留的文件名称 
    [PAMID]              INT             NOT NULL,                        --PAMID
    [PLCID]              INT             NOT NULL,                        --PLCID
    [ParamValue]         VARCHAR  (50)       NULL DEFAULT (''),           --PLC参数数值
    [UploadUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UploadTime]         DATETIME        NOT NULL DEFAULT GETDATE()       --更新时间
);

--PLC信息参数类别表
IF OBJECT_ID('Mes_PLC_ApplModel_List') is not null
DROP TABLE Mes_PLC_ApplModel_List;
CREATE TABLE [dbo].[Mes_PLC_ApplModel_List] (
    [ApplModel]          VARCHAR  (10)   NOT NULL,                        --应用模块编码: [Mes_PLC_ApplModel_List]
    [ApplDsca]           VARCHAR  (50)   NOT NULL,                        --应用模块名称
    [Status]             INT             NOT NULL DEFAULT (1)             --订单状态: 1:预订义; 0:新增, -1:修改, -2:删除
);

--初始化PLC信息参数类别表
INSERT INTO Mes_PLC_ApplModel_List
(ApplModel, ApplDsca) VALUES
('RT',      'RFID Trigger' ),            --RFID触发(读头进行读取)
('AT',      'Alarm Trigger'),            --设备报警触发
('MT',      'Material Trigger'),         --物料拉动触发
('QT',      'Qty Trigger'),              --产量计数触发
('ET',      'Engergy Trigger'),          --电表计量触发
('VS',      'Values Send'),              --PLC参数派发(写入OPC: 参数值派发)
('CS',      'Cutover Send'),             --PLC参数派发(写入OPC: 换更产品请求)
('QS',      'Qty Send'),                 --PLC参数派发(写入OPC: 计划产量)
('NA',      'Ignore');                   --忽略备用

--PLC参数派发接口表
IF OBJECT_ID('Mes_PLC_TransInterface') is not null
DROP TABLE Mes_PLC_TransInterface;
CREATE TABLE [dbo].Mes_PLC_TransInterface (
    [BATCHNUM]           VARCHAR  (15)   NOT NULL,                        --客户端操作批次号
    [PLCID]              INT             NOT NULL,                        --PLCID, 设备标志, 用以分组
    [SOURCEID]           INT             NOT NULL,                        --PLC参数表源ID
    [ParamName]          VARCHAR  (50)   NOT NULL,                        --PLC参数名称,Tag值
    [ParamType]          VARCHAR  (10)   NOT NULL,                        --PLC参数类型: (BYTE, DWORD, BOOL, ...)
    [ParamValue]         VARCHAR  (50)   NOT NULL,                        --PLC参数数值,等待派发
    [OperateCommand]     VARCHAR  (10)   NOT NULL,                        --操作命令: RESET:重置; WRITE:写入; READ:读取; 
    [OperateTime]        DATETIME        NOT NULL DEFAULT GETDATE(),      --操作工派发时间(点击界面按钮时间)
    [DownloadTime]       DATETIME            NULL,                        --派发时间
    [FeedBackTime]       DATETIME            NULL,                        --回馈时间(派发完成时间)
    [OperateUser]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --派发人员
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:准备数据; 1:正在派发; 2:成功; <=-2:失败(小于等于-2均为失败, 其具体值代表不同的失败类型)
);

--PLC参数派发接口日志表
IF OBJECT_ID('Log_Mes_PLC_TransInterface') is not null
DROP TABLE Log_Mes_PLC_TransInterface;
CREATE TABLE [dbo].Log_Mes_PLC_TransInterface (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [BATCHNUM]           VARCHAR  (15)   NOT NULL,                        --客户端操作批次号
    [PLCID]              INT             NOT NULL,                        --PLCID, 设备标志, 用以分组
    [SOURCEID]           INT             NOT NULL,                        --PLC参数表源ID
    [ParamName]          VARCHAR  (50)   NOT NULL,                        --PLC参数名称,Tag值
    [ParamType]          VARCHAR  (10)   NOT NULL,                        --PLC参数类型: (BYTE, DWORD, BOOL, ...)
    [ParamValue]         VARCHAR  (50)   NOT NULL,                        --PLC参数数值,等待派发
    [OperateCommand]     VARCHAR  (10)   NOT NULL,                        --操作命令: RESET:重置; WRITE:写入; READ:读取; 
    [OperateTime]        DATETIME        NOT NULL,                        --操作工派发时间(点击界面按钮时间)
    [DownloadTime]       DATETIME            NULL,                        --派发时间
    [FeedBackTime]       DATETIME            NULL,                        --回馈时间(派发完成时间)
    [OperateUser]        NVARCHAR (50)   NOT NULL DEFAULT (N''),          --派发人员
    [Status]             INT             NOT NULL DEFAULT (0),            --订单状态: 0:准备数据; 1:等待派发; 2:成功; <=-2:失败(小于等于-2均为失败, 其具体值代表不同的失败类型)
    [LogTime]            DATETIME        NOT NULL DEFAULT GETDATE()       --备份时间
);

--物料阈值记录表
IF OBJECT_ID('Mes_Threshold_List') is not null
DROP TABLE Mes_Threshold_List;
CREATE TABLE [dbo].[Mes_Threshold_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [ItemNumber]         VARCHAR  (50)   NOT NULL,                        --原料编码
    [ItemName]           NVARCHAR (50)   NOT NULL,                        --原料名称 (此处需求写的不好, 和其它处不一致)
    [MaxPullQty]         NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --最大拉动数量
    [MinTrigQty]         NUMERIC  (18, 4)NOT NULL DEFAULT (0),            --拉动时限,分钟,超过此值, 即认为超时, 应该是整数类型,起初错误理解为触发数量
    [UOM]                NVARCHAR (15)   NOT NULL DEFAULT (N'个'),        --用料计量单位
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--RFID读取设备配置表
IF OBJECT_ID('Mes_RFID_Reader_List') is not null
DROP TABLE Mes_RFID_Reader_List;
CREATE TABLE [dbo].[Mes_RFID_Reader_List] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [ReaderCode]         VARCHAR  (50)   NOT NULL DEFAULT (''),           --读取头编码
    [ReaderName]         NVARCHAR (50)   NOT NULL,                        --读取头名称
    [AbnormalPoint]      INT                 NULL DEFAULT (0)             --RFID读取头对应的下线点编号 
    [ParamName]          VARCHAR  (50)   NOT NULL,                        --参数名称
    [ParamValue]         VARCHAR  (50)   NOT NULL,                        --参数数值
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--序列号记录表
IF OBJECT_ID('Mes_SerialNoPoolList') is not null
DROP TABLE Mes_SerialNoPoolList;
CREATE TABLE [dbo].Mes_SerialNoPoolList(
    [SerialName]   VARCHAR  (50)        NOT NULL,                         --序列号名称
    [SerialPrefix] VARCHAR  (5)         NOT NULL,                         --序列号前缀
    [SerialNo]     NUMERIC  (18,0)      NOT NULL DEFAULT 0,               --最后一次的获取序列值
    [ModifyTime]   DATETIME             NOT NULL DEFAULT GETDATE()        --最后一次的获取时间
);

--设备记录表
IF OBJECT_ID('Equ_DeviceInfoList') is not null
DROP TABLE Equ_DeviceInfoList;
CREATE TABLE [dbo].Equ_DeviceInfoList(
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [DeviceCode]         VARCHAR  (20)       NULL,                        --设备编码
    [DeviceName]         NVARCHAR (50)       NULL,                        --设备名称
    [DeviceVendor]       NVARCHAR (50)       NULL,                        --供应厂商
    [DeviceUseDate]      DATETIME            NULL,                        --投产时间
    [DevicePartsFile]    NVARCHAR (100)      NULL,                        --硬件组成列表(文件URL)
    [DeviceManualFile]   NVARCHAR (100)      NULL,                        --设备操作说明书(文件URL)
    [DeviceComment]      NVARCHAR (100)      NULL,                        --设备说明
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--设备保养规范表
IF OBJECT_ID('Equ_PmSpecList') is not null
DROP TABLE Equ_PmSpecList;
CREATE TABLE [dbo].[Equ_PmSpecList](
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [DeviceName]         NVARCHAR (50)       NULL,                        --设备名称
    [PmSpecCode]         NVARCHAR (50)       NULL,                        --规范编号
    [PmSpecName]         NVARCHAR (50)       NULL,                        --规范名称
    [PmLevel]            NVARCHAR (20)       NULL,                        --保养类型: "一级保养", "二级保养"
    [PmSpecFile]         NVARCHAR (100)      NULL,                        --保养规范(文件URL)
    [PmSpecComment]      NVARCHAR (100)      NULL,                        --规范说明
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--设备保养计划表
IF OBJECT_ID('Equ_PmPlanList') is not null
DROP TABLE Equ_PmPlanList;
CREATE TABLE [dbo].[Equ_PmPlanList](
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [DeviceName]         NVARCHAR (50)       NULL,                        --设备名称
    [PmSpecCode]         NVARCHAR (50)       NULL,                        --规范编号
    [PmPlanCode]         NVARCHAR (50)       NULL,                        --保养计划编号
    [PmPlanName]         NVARCHAR (50)       NULL,                        --保养计划名称
    [PmCycleTime]        INT             NOT NULL,                        --保养周期(天)
    [PmTimeUsage]        INT             NOT NULL,                        --保养耗时(分钟)
    [PmFirstDate]        DATETIME            NULL,                        --首次保养日期
    [PmContinueTimes]    INT                 NULL DEFAULT(0),             --保养持续次数
    [PmPreAlarmDates]    INT                 NULL DEFAULT(3),             --提前提醒天数
    [PmPlanComment]      NVARCHAR (100)      NULL,                        --保养计划说明
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0),            --订单状态: 0:新增, -1:修改, -2:删除
    [PmLevel]            NVARCHAR (20)       NULL                         --保养类型: "一级保养", "二级保养"
);

--设备保养信息记录表
IF OBJECT_ID('Equ_PmRecordList') is not null
DROP TABLE Equ_PmRecordList;
CREATE TABLE [dbo].[Equ_PmRecordList](
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [DeviceName]         NVARCHAR (50)       NULL,                        --设备名称
    [PmSpecCode]         NVARCHAR (50)       NULL,                        --规范编号
    [PmPlanCode]         NVARCHAR (50)       NULL,                        --保养计划编号
    [PmType]             NVARCHAR (20)       NULL,                        --保养类别: "计划内保养", "计划外保养"
    [PmLevel]            NVARCHAR (20)       NULL,                        --保养类型: "一级保养", "二级保养"
    [PmStartDate]        DATE                NULL,                        --保养开始时间(精确到天)
    [PmFinishDate]       DATE                NULL,                        --保养完成时间(精确到天)
    [PmPlanDate]         DATE                NULL,                        --此次保养所属的保养计划的日期(精确到天)
    [PmDoTimes]          INT                 NULL,                        --此次保养所属的保养计划的次数
    [PmOper]             NVARCHAR (50)       NULL,                        --保养人
    [PmComment]          NVARCHAR (100)      NULL,                        --保养记录说明
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--设备报警记录表
IF OBJECT_ID('Equ_DeviceAlarm') is not null
DROP TABLE Equ_DeviceAlarm;
CREATE TABLE [dbo].[Equ_DeviceAlarm](
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [ProcessCode]        VARCHAR  (50)   NOT NULL DEFAULT (''),           --工序编号
    [DeviceName]         NVARCHAR (50)       NULL,                        --设备名称
    [AlarmItem]          NVARCHAR (50)   NOT NULL DEFAULT (''),           --报警项
    [AlarmTime]          DATETIME        NOT NULL DEFAULT GETDATE(),      --报警时间
    [DealWithResult]     NVARCHAR (50)   NOT NULL DEFAULT (''),           --处理结果: 已处理; 未处理
    [DealWithTime]       DATETIME            NULL ,                       --处理完成时间
    [DealWithOper]       NVARCHAR (50)       NULL ,                       --处理人
    [DealWithComment]    NVARCHAR (100)      NULL,                        --报警处理说明
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE(),      --更新时间
    [Status]             INT             NOT NULL DEFAULT (0)             --订单状态: 0:新增, -1:修改, -2:删除
);

--设备一级保养点检内容表
IF OBJECT_ID('Equ_FirstLevelTestContent') is not null
DROP TABLE Equ_FirstLevelTestContent;
CREATE TABLE [dbo].[Equ_FirstLevelTestContent] (
    [ID]                 INT             NOT NULL,                         -- (系统自动生成)
    [InspectionContent]  NVARCHAR  (50)   NULL                          --点检内容
);
INSERT INTO Equ_FirstLevelTestContent (ID, InspectionContent)
VALUES
(1, N'设备操作机构灵活可靠'),
(2, N'配合间隙传动正常'),
(3, N'工装夹具安装及使用良好'),
(4, N'安全装置、照明设施良好'),
(5, N'润滑系统清洁畅通、润滑良好'),
(6, N'电器装置绝缘良好安全可靠'),
(7, N'电器箱内外清洁无灰尘');

--设备一级保养问题记录表
IF OBJECT_ID('Equ_FirstLevelInspectionProblem') is not null
DROP TABLE Equ_FirstLevelInspectionProblem;
CREATE TABLE [dbo].[Equ_FirstLevelInspectionProblem](
	[ID]                [int] IDENTITY(1,1) NOT NULL,
	[InspectionProblem] [nvarchar](max) NULL,
	[InspectionDate]    [datetime] NULL,
	[DeviceCode]        [varchar](20) NULL,
	[FindProblem]       [int] NULL,
	[RepairProblem]     [int] NULL,
	[ReaminProblem]     [int] NULL,
	[PmRecordID]        [int] NULL
);

--设备二级保养点检内容表
IF OBJECT_ID('Equ_SecondLevelTestContent') is not null
DROP TABLE Equ_SecondLevelTestContent;
CREATE TABLE [dbo].[Equ_SecondLevelTestContent] (
    [ID]                 INT             NOT NULL,                         -- (系统自动生成)
    [InspectionContent]  NVARCHAR  (50)   NULL                          --点检内容
);
INSERT INTO Equ_SecondLevelTestContent (ID, InspectionContent)
VALUES
(1, N'检查液压站、油管、油缸有无漏油现象；清理润滑，各滑轨润滑、调整'),
(2, N'模具、各紧固螺栓是否缺失、松动，配齐各螺栓紧固件'),
(3, N'检查检测电气绝缘、接地保护、电线防护等电器安全设施是否齐全有效'),
(4, N'清理电气配电箱内各元器件上灰尘，检查并紧固各接线端子、接线排及电气机械部分，检查电器冷却系统'),
(5, N'各按钮开关、光电开关灵敏齐全有效');


--设备二级保养问题记录表
IF OBJECT_ID('Equ_SecondLevelInspectionProblem') is not null
DROP TABLE Equ_SecondLevelInspectionProblem;
CREATE TABLE [dbo].[Equ_SecondLevelInspectionProblem](
	[ID]                [int] IDENTITY(1,1) NOT NULL,
	[InspectionProblem] [nvarchar](max) NULL,    --保养前存在的问题
	[InspectionDate]    [datetime] NULL,         --保养日期
	[DeviceCode]        [varchar](20) NULL,      --设备编号
	[MaintenceTime]     [int] NULL,              --保养耗时2
	[PowerLine]         [varchar] NULL,          --电源线绝缘值
	[GroundLead]        [varchar] NULL,          --接地线
	[ReplacePart]       [nvarchar](max) NULL,    --更换部位
	[ReplaceName]       [nvarchar](max) NULL,    --更换名称
	[ReplaceCount]      [int] NULL,              --更换件数
	[PmRecordID]        [int] NULL
);



--每月预算产量表
IF OBJECT_ID('Report_MonthBudget') is not null
DROP TABLE Report_MonthBudget;
CREATE TABLE [dbo].[Report_MonthBudget](
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [BudgetProduction]   NVARCHAR (50)       NULL ,                       --处理人
    [UpdateUser]         NVARCHAR (50)   NOT NULL DEFAULT (N''),          --更新用户
    [UpdateTime]         DATETIME        NOT NULL DEFAULT GETDATE()       --更新时间
 
);
--设备报警记录表
IF OBJECT_ID('Log_Mfg_Plc_Tag_Trig') is not null
DROP TABLE Log_Mfg_Plc_Tag_Trig;
CREATE TABLE [dbo].[Log_Mfg_PLC_Tag_Trig](
    [ID]                 INT IDENTITY (1, 1) NOT NULL,                    -- (系统自动生成)
    [TagName]          VARCHAR  (50)   NOT NULL,                          --PLC参数名称: OPC Tag值
    [TagValue]         VARCHAR  (50)   NOT NULL,                          --PLC参数数值
    [ProcessCode]      VARCHAR  (50)   NOT NULL DEFAULT (''),             --工序编号
    [Category]         VARCHAR  (10)   NOT NULL DEFAULT (''),             --动作类型
    [TripTime]         DATETIME        NOT NULL DEFAULT GETDATE()         --更新时间
);


/*
-- INIT DB DATA
  INSERT INTO UserM_Menu (MenuNo,  MenuName,   ParentNo, MenuTyp, MenuTag, Image1,                        MenuAddr)  VALUES
                         ('X001', '产线管理', '1000',    1,       1,       'fa fa-sitemap fa-fw'        , '../Mfg/BaseConfig/LineConfig.aspx'  ),
                         ('X002', '工序管理', '1000',    1,       1,       'fa fa-cogs fa-fw'           , '../Mfg/BaseConfig/ProcessConfig.aspx' );


  INSERT INTO UserM_OperateInfo(OperateNo, MenuNo, OperateName,   MenuName  ) values
                               ('X001',    'X001', '产线管理',     '产线管理' ),
                               ('X002',    'X002', '工序管理',     '工序管理' );

  INSERT INTO Mes_Line_List ([LineCode],[LineName],                  [LineDsca],                [LineCapacity], [LineHeadCount] ,[ShiftHours] ,[UpdateTime] ,[UpdateUser]) VALUES
                            ('LNRT-001',N'力诺瑞特平板集热器生产线',N'力诺瑞特平板集热器生产线', 240,           11,              8,            getdate(),    'SYS'  )

  INSERT INTO Mes_Process_List ( [InturnNumber],[ProcessCode],[ProcessName],[ProcessDsca], [ProcessBeat],[ProcessManual]) values
                                (1,            'A01',        '铝型材上料',  '铝型材上料工序',120,          ''),
                                (2,            'A02',        '欲组装',      '欲组装工序',   120,          ''),
                                (3,            'A03',        '归正',        '归正工序',     120,          ''),
                                (4,            'A04',        '组框',        '组框工序',     120,          '');
                              -- LNRT END
*/


