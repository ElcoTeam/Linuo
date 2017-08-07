--SELECT * FROM ERP_Inventory_List;


/*
INSERT INTO ERP_Inventory_List ( MATNR, MAKTX, INVQTY )
        SELECT 
        DISTINCT
             MTL.ItemNumber      ItemNumber
            ,MTL.ItemDsca        ItemDsca
            ,0
        FROM
             MFG_WO_MTL_List MTL
            ,MFG_WO_List WO
        WHERE
                1=1
            AND WO.ID = 70
            AND MTL.WorkOrderNumber  = WO.ErpWorkOrderNumber
            AND MTL.WorkOrderVersion = WO.MesWorkOrderVersion


 --           SELECT * FROM MFG_WO_List;

 select * from ERP_WO_Material_Transfer;

 select * from ERP_WO_REPORT_COMPLETE where AUFNR = '000020075733';
 select * from MFG_WO_LIST WHERE ErpWorkOrderNumber = '000020075733';

 BEGIN TRAN
 UPDATE MFG_WO_LIST SET Mes2ErpCfmQty=0, Mes2ErpCfmStatus=-1 WHERE ErpWorkOrderNumber = '000020075733';
 DELETE FROM ERP_WO_REPORT_COMPLETE where AUFNR = '000020075733';
 COMMIT;
 */


/*
--select * from Mes_Process_List;
--select * from MFG_WO_List;
--  select * from Mes_Process_List;
--  select * from MFG_WO_MTL_Pull order by pulltime desc;
--  select * from [Log_Mfg_Plc_Tag_Trig] 
--  where 
--  1=1 
--  AND ( 
--     tagname = 'LN56.IOBox06.InputBool02' 
--  or tagname = 'ln58.iobox08.inputbool02' )
--  and Category='MT'
--  order by triptime desc
-- SELECT * FROM Mes_Energy_Record ORDER BY UpdateTime DESC;

-- SELECT * FROM Mes_PLC_Parameters     
--        Mes_PLC_Parameters, Mes_PLC_List 
--    WHERE 
--        Mes_PLC_Parameters.PLCID = Mes_PLC_List.ID
--    AND Mes_PLC_Parameters.ApplModel = 'QT'
--    AND Mes_PLC_List.GoodsCode = '0000000000';

UPDATE Mes_PLC_Parameters SET ItemNumber = '00000000' + ItemNumber where  len(ItemNumber)>0 and len(ItemNumber)<11;
UPDATE MFG_WO_MTL_Pull    SET ItemNumber = '00000000' + ItemNumber where  len(ItemNumber)>0 and len(ItemNumber)<11;
UPDATE Mes_Threshold_List SET ItemNumber = '00000000' + ItemNumber where  len(ItemNumber)>0 and len(ItemNumber)<11;

UPDATE
MFG_WO_MTL_Pull 
SET MFG_WO_MTL_Pull.ItemDsca = ISNULL(MTL.ItemName, 'test dsca')
FROM MFG_WO_MTL_Pull PULL LEFT JOIN Mes_Threshold_List MTL ON PULL.ItemNumber = MTL.ItemNumber

*/

------------
/*
SELECT * FROM mes_config;
SELECT * FROM mfg_wo_list;

UPDATE mfg_wo_list SET
 MesLeftQty1 = 1
,MesLeftQty2 = 1
,MesDiscardQty = 1
,MesSubPlanFlag = 0
,MesStatus = 3
,Mes2ErpCfmQty = 0
,Mes2ErpCfmStatus = -1
*/
---+++++++++

--select * from Mes_PLC_TagList where [所属模块] ='物料拉动'
/*
--ALTER TABLE [Mes_PLC_TagList] ADD PlcCabinet varchar(5) null;

TRUNCATE TABLE [Mes_PLC_TagList];

DELETE FROM Mes_PLC_Parameters WHERE PLCID IN (SELECT ID FROM Mes_PLC_List WHERE GoodsCode IN ('0000000000','000000002120360056'));
DELETE FROM MES_PLC_LIST WHERE GoodsCode IN ('0000000000','000000002120360056');

UPDATE Mes_Plc_TagList set PlcCabinet  =  left(tag, patindex('%[._]%',tag)-1);

INSERT INTO Mes_PLC_List (GoodsCode, PLCName, PLCCode, PLCType, PLCModel, PLCCabinet)
SELECT DISTINCT '000000002120360056' GoodsCode, DeviceName PLCName, DeviceCode PLCCode, PLCBrand PLCType, PlcModel PlcModel, PLCCabinet PLCCabinet 
from Mes_PLC_TagList ORDER BY PLCCODE;

INSERT INTO Mes_PLC_Parameters (PLCID, ParamName, ParamValue, ParamType, OperateType, ParamDsca, ItemNumber, ProcessCode, ApplModel)
SELECT PLC.ID PLCID, 
TagList.Tag ParamName, 
ISNULL([TagList].[产品A参数值(ParaValueA)], '')  ParamValue, 
TagList.OPCType ParamType, 
[TagList].[I/OType] OperateType, 
TagList.TagName ParamDsca,
CASE TagList.[所属模块] 
    WHEN '物料拉动' THEN [参数值说明（ValueInf）]
    ELSE ''
END ItemNumber, 
CASE TagList.[所属模块] 
    WHEN '物料拉动' THEN [产品A参数值(ParaValueA)]
    ELSE ''
END ProcessCode,
CASE TagList.[所属模块] 
    WHEN '参数派发'    THEN 'VS'
    WHEN '物料拉动'    THEN 'MT'
    WHEN '显示'        THEN 'NA'
    WHEN 'RFID（检测到位）'     THEN 'RT'
    WHEN '报警'     THEN 'AT'
    WHEN '备用'     THEN 'NA'
    ELSE                 'NA'
END ApplModel
FROM Mes_PLC_TagList TagList,
     Mes_PLC_List  PLC
WHERE 
    TagList.DeviceCode = PLC.PLCCode 
AND TagList.PlcCabinet = PLC.PlcCabinet 
AND PLC.GoodsCode      = '000000002120360056'
ORDER BY PLCID;


UPDATE MES_PLC_LIST SET ProcessCode = '1010' where plccode in ('CP16','CP17','CP18','RP05');
UPDATE MES_PLC_LIST SET ProcessCode = '1020' where plccode in ('CP15');
UPDATE MES_PLC_LIST SET ProcessCode = '1030' where plccode in ('CP21');
UPDATE MES_PLC_LIST SET ProcessCode = '1050' where plccode in ('CP104','RP07');
UPDATE MES_PLC_LIST SET ProcessCode = '1060' where plccode in ('CP19');
UPDATE MES_PLC_LIST SET ProcessCode = '1070' where plccode in ('CP27');
UPDATE MES_PLC_LIST SET ProcessCode = '1080' where plccode in ('CP26','CP28');
UPDATE MES_PLC_LIST SET ProcessCode = '1090' where plccode in ('CP27');
UPDATE MES_PLC_LIST SET ProcessCode = '2010' where plccode in ('CP01');
UPDATE MES_PLC_LIST SET ProcessCode = '2020' where plccode in ('CP105');
UPDATE MES_PLC_LIST SET ProcessCode = '2030' where plccode in ('RP01');
UPDATE MES_PLC_LIST SET ProcessCode = '2040' where plccode in ('CP05');
UPDATE MES_PLC_LIST SET ProcessCode = '2050' where plccode in ('CP03');
UPDATE MES_PLC_LIST SET ProcessCode = '2060' where plccode in ('CP07');
UPDATE MES_PLC_LIST SET ProcessCode = '2070' where plccode in ('CP10');
UPDATE MES_PLC_LIST SET ProcessCode = '2080' where plccode in ('RP02');
UPDATE MES_PLC_LIST SET ProcessCode = '2090' where plccode in ('CP08','RP02');
UPDATE MES_PLC_LIST SET ProcessCode = '3010' where plccode in ('RP03');
UPDATE MES_PLC_LIST SET ProcessCode = '3020' where plccode in ('CP11');
UPDATE MES_PLC_LIST SET ProcessCode = '3110' where plccode in ('RP04','CP14');


UPDATE MES_PLC_Parameters 
SET MES_PLC_Parameters.ProcessCode = PRO.ProcessCode 
FROM [dbo].[Mes_Process_List] AS PRO
WHERE MES_PLC_Parameters.ApplModel= 'MT'
AND [MES_PLC_Parameters].ParamValue = PRO.ProcessName;

UPDATE MES_PLC_Parameters SET OperateCommand = 'WRITE' WHERE OperateType = 'W' OR OperateType = 'RW';
UPDATE MES_PLC_Parameters SET ApplModel = 'QS' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE [参数值说明（ValueInf）] ='随订单变化');
UPDATE MES_PLC_Parameters SET ApplModel = 'NA' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE [参数值说明（ValueInf）] ='现在取消不用');
UPDATE MES_PLC_Parameters SET ApplModel = 'CS' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '换更产品请求');
UPDATE MES_PLC_Parameters SET ApplModel = 'ET' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '有功电能');
UPDATE MES_PLC_Parameters SET ApplModel = 'QT' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname LIKE '完成数量%');
*/
--truncate table Mes_Threshold_List;
INSERT INTO
 Mes_Threshold_List (MaxPullQty, MinTrigQty, ItemNumber, ProcessCode, UOM, ItemName)
values
(100,30,'2710001085','2010','EA','镀铝锌板 1945*945*0.35'),
(100,30,'2710001075','2040','EA','角码 L=10MM'),
(100,30,'2710001068','2040','EA','上下边框LXCP-89 2000mm 6063-T5'),
(100,30,'2710001071','2040','EA','右边框LXCP-89 1000mm 6063-T5（圆孔）'),
(100,30,'2710001072','2040','EA','左边框LXCP-89 1000mm 6063-T5（无孔）'),
(100,30,'3110000230','2080','KG','平板用密封胶(黑色-270kg/桶）'),
(100,30,'3050000094','2090','EA','聚酯保温棉 短边左右保温 无孔985*66*18'),
(100,30,'3050000095','2090','EA','聚酯保温棉 短边左右保温 有孔985*66*18'),
(100,30,'3050000096','2090','EA','聚酯保温棉 长边保温1952*66*18'),
(100,30,'3050000053','2090','EA','聚酯保温棉 底部保温1948*948*35'),
(100,30,'3070100599','2090','EA','板芯固定卡子 弹簧钢丝Φ1.0mm'),
(100,30,'3070400373','2090','EA','密封圈 排气口用 黑色橡胶 φ22 高8.5mm 邵氏硬度50°至60°'),
(100,30,'3110000052','2090','EA','标签 PET75*50mm'),
(100,30,'3070800393','3020','EA','玻璃 丝印非镀膜低铁超白布纹钢化 1972*972*3.2 透光率≥91.75%'),
(100,30,'2710001073','3030','EA','上下压条LXCP-90 2000mm 6063-T5'),
(100,30,'2710001074','3030','EA','左右压条LXCP-90 1000mm 6063-T5'),
(100,30,'3070400374','3030','EA','护丝帽 黑色橡胶φ23*16*1.5 邵氏硬度50°至60°'),
(100,30,'3070400265','3030','EA','密封圈 圆形 黑色橡胶 内径φ22变φ23 高11mm 邵氏硬度50°至60°'),
(100,30,'3080401085','3030','EA','合格证 平板集热器'),
(100,30,'3110000126','3030','EA','标签 PET40*100mm'),
(100,30,'3080401084','3030','EA','标贴 拉丝不锈钢带粘胶78mm*18mm'),
(100,30,'3110000220','3080','KG','PE热收缩膜 厚0.07*宽1344*C PE膜净重25Kg/卷'),
(100,30,'3110000005','3090','M','黄胶带 60mm*100码'),
(100,30,'3080200170','3090','EA','泡沫堵头 EPS(165+5+130)*80*40平板集热器用'),
(100,30,'3110000213','3090','KG','打包带PP12010J'),
(100,30,'3080101573','3090','EA','纸箱BD-2.5 平板集热器包装箱 外径1015*300*95 S0.9'),
(100,30,'3030200745','3090','KG','铜管 TP2盘管 φ22*0.6*C'),
(100,30,'3070100764','1010','EA','铜接头 焊接接头HPb59-1 长55mm φ25焊接喇叭口 G1/2外丝平口'),
(100,30,'3110000215','1010','KG','银焊丝Φ1.8（AG7%）（盘丝）'),
(100,30,'3030200849','1020','KG','紫铜盘管 Φ10*0.45'),
(100,30,'3110000216','1020','KG','银焊丝Φ1（AG5%）（盘丝）'),
(100,30,'3110000227','1020','KG','煤气50KG'),
(100,30,'3110000063','1020','KG','氧气'),
(100,30,'3020000218','1080','EA','吸热板 膜HG 1945*945*0.3 α≥92% εh(80℃)≤10%');


--truncate table mes_process_list;
insert into Mes_Process_List ( InturnNumber, ProcessCode, AbnormalEnable, AbnormalRegion, ProcessName, ProcessDsca) values
(10,   '1010',0, 1, '22*0.6铜管加工','22*0.6铜管加工'),
(20,   '1020',0, 1, '10*0.45铜管加工','10*0.45铜管加工'),
(30,   '1030',0, 1, '火焰钎焊','火焰钎焊'),
(40,   '1040',0, 1, '铜排上线','铜排上线'),
(50,   '1050',0, 1, '铜管压弯','铜管压弯'),
(60,   '1060',1, 1, '铜排气密性检测','铜排气密性检测'),
(70,   '1070',0, 2, '吸热板上料','吸热板上料'),
(80,   '1080',0, 2, '激光焊','激光焊'),
(90,   '1090',1, 2, '板芯气密性检测','板芯气密性检测'),
(100,  '2010',0, 3, '底板上料','底板上料'),
(110,  '2020',0, 3, '角码加工','角码加工'),
(120,  '2030',0, 3, '铝型材加工','铝型材加工'),
(130,  '2040',0, 3, '预组框','预组框'),
(140,  '2050',0, 3, '组角','组角'),
(150,  '2060',0, 3, '长边背板压合','长边背板压合'),
(160,  '2070',0, 3, '短边背板压合','短边背板压合'),
(170,  '2080',0, 3, '边框涂胶','边框涂胶'),
(180,  '2090',0, 3, '安装底部保温棉','安装底部保温棉'),
(190,  '2100',0, 3, '边框板芯装配','边框板芯装配'),
(200,  '3010',0, 3, '玻璃板涂胶','玻璃板涂胶'),
(210,  '3020',0, 3, '玻璃板安装','玻璃板安装'),
(220,  '3030',0, 3, '预装压条','预装压条'),
(230,  '3040',0, 3, '扣条压合','扣条压合'),
(240,  '3050',1, 3, 'MES码贴标','MES码贴标'),
(250,  '3060',0, 3, 'PET贴标','PET贴标'),
(260,  '3070',0, 3, '封边','封边'),
(270,  '3080',0, 3, '热缩','热缩'),
(280,  '3090',0, 3, '产品包装','产品包装'),
(290,  '3100',0, 3, '打包','打包'),
(300,  '3110',0, 3, '码垛','码垛');



update mfg_wo_list
set 
 ErpPlanCreateTime  = getdate()
,ErpPlanStartTime   = getdate()
,ErpPlanFinishTime  = getdate()
,ErpPlanReleaseTime = getdate()
,MesPlanStartTime   = getdate()
,MesPlanFinishTime  = getdate()

------

INSERT INTO MFG_WIP_Data_RFID(WorkOrderNumber, WorkOrderVersion, ProcessCode, RFID, UpdateUser)
VALUES
('20075731', 0, '1', '7890', 'TESTUSER'),
('20075731', 0, '2', '7890', 'TESTUSER'),
('20075731', 0, '3', '7890', 'TESTUSER'),
('20075731', 0, '4', '7890', 'TESTUSER'),
('20075731', 0, '5', '7890', 'TESTUSER'),
('20075731', 0, '6', '7890', 'TESTUSER'),
('20075731', 0, '7', '7890', 'TESTUSER'),
('20075731', 0, '8', '7890', 'TESTUSER'),
('20075731', 0, '9', '7890', 'TESTUSER')
--++++

------------------------
SELECT * FROM Mes_SerialNoPoolList;
SELECT * FROM Mes_PLC_TransInterface;

--truncate table Mes_PLC_TransInterface;

SELECT  PLCID, ID, ParamName, ParamType, ParamValue, OperateCommand
FROM Mes_PLC_Parameters
WHERE (
 --OperateCommand = 'WRITE'
 --OR 
 OperateCommand = 'RESET' 
);


SELECT * FROM Mes_PLC_List WHERE GoodsCode='000000002120360056';


--update Mes_PLC_Parameters set OperateCommand = 'RESET' WHERE ID IN( 1642, 1644, 1670);
---+++++++++++++++++++++

    -- 倒入PLC的统计出来的半成品数据
    BEGIN TRAN

    DELETE FROM Mes_PLC_Parameters where PLCID in (select ID FROM Mes_PLC_List where GoodsCode = '000000002120360056')
    DELETE FROM Mes_PLC_List where GoodsCode = '000000002120360056';

    DECLARE @CP VARCHAR(20);
    DECLARE @LN VARCHAR(20);
    DECLARE @TT INT;

    DECLARE RECNEW CURSOR FOR
    SELECT 
       DISTINCT 
       left(right(tag, len(tag) - patindex('%[._]%', tag)), patindex('%[._]%',right(tag, len(tag) - patindex('%[._]%', tag)))-1) CP
      ,left(tag, patindex('%[._]%',tag)-1) LN
     FROM LinuoTag.dbo.TagsInfo1  
    ORDER BY CP

    OPEN RECNEW;

    FETCH NEXT FROM RECNEW INTO @CP, @LN;
    WHILE @@FETCH_STATUS = 0
    BEGIN

    --逐个PLC插入
        INSERT INTO Mes_PLC_List (  GoodsCode,           PLCName,  PLCType,   PLCModel, PLCCabinet,  UpdateUser )
                           VALUES( '000000002120360056', @CP,     'SIEMENS', 'SMT200', @LN,         N'TEST'    )

    --获取最后一个刚刚插入记录的ID  (本连接的,当下作用域之内的新增ID值)
        SELECT @TT = SCOPE_IDENTITY()

    --每个PLC的所有参数都复制一遍
        INSERT INTO Mes_PLC_Parameters( PLCID, ParamName, ParamDsca, ParamValue, ParamType, OperateType, OperateCommand, ItemNumber,  UpdateUser )
                                 SELECT @TT,   TAG,       Info,      0,          'DWORD',   'RW',        'WRITE',        '',          N'TEST'
                                 FROM LinuoTag.dbo.TagsInfo1 
                                 WHERE left(right(tag, len(tag) - patindex('%[._]%', tag)), patindex('%[._]%',right(tag, len(tag) - patindex('%[._]%', tag)))-1) = @CP;
        FETCH NEXT FROM RECNEW INTO @CP, @LN;
    END
    CLOSE RECNEW;
    DEALLOCATE RECNEW;

COMMIT;




select 
  left(tag, patindex('%[._]%',tag)-1)
 ,left(right(tag, len(tag) - patindex('%[._]%', tag)), patindex('%[._]%',right(tag, len(tag) - patindex('%[._]%', tag)))-1)
 ,right(right(tag, len(tag) - patindex('%[._]%', tag)), len(right(tag, len(tag) - patindex('%[._]%', tag))) - patindex('%[._]%', right(tag, len(tag) - patindex('%[._]%', tag))))
 ,right(tag, len(tag) - patindex('%[._]%', tag)) 
 ,tag from LinuoTag.dbo.TagsInfo1 order by tag;

 /*
 拆分字符串样例程序:开始
 */
    DECLARE @cIndex INT;
    DECLARE @sIdList VARCHAR(MAX);
    DECLARE @ListTB TABLE(ID INT);

    SELECT @sIdList = '1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049';
    SELECT @cIndex = CHARINDEX(',', @sIdList);
    WHILE @cIndex>0 
    BEGIN
        INSERT INTO @ListTB VALUES(CONVERT(INT, LEFT(@sIdList, @cIndex - 1)));
        SELECT @sIdList = RIGHT(@sIdList, LEN(@sIdList) - @cIndex);        
        SELECT @cIndex = CHARINDEX(',', @sIdList, @cIndex);
    END    

    IF LEN(@sIdList) > 0
    BEGIN
        INSERT INTO @ListTB VALUES(CONVERT(INT, @sIdList));
    END

    DECLARE @RtnMsg VARCHAR(MAX);
    SET @RtnMsg='';

    SELECT @RtnMsg = @RtnMsg +CONVERT(VARCHAR, ID) + ';' FROM @ListTB

    SELECT @RtnMsg;

/*拆分字符串样例程序: 结束*/

SELECT * FROM MES_PLC_LIST;
SELECT * FROM Mes_PLC_Parameters;

update mes_plc_parameters set ParamValue = id;
--UPDATE Mes_PLC_Parameters SET ParamName = UPPER(PARAMNAME) WHERE PLCID=2
--UPDATE Mes_PLC_Parameters SET OperateType = 'W' WHERE PLCID=1 AND ParamType='BOOL';
/*
INSERT INTO MES_PLC_LIST (GoodsCode, PLCNAME, PLCType, PLCModel, PLCCABINET) VALUES
('ABCD0', N'底板上料直角坐标',     'SIEMENS',   'SMART200 ST30', 'CP01'),
('EFGH',  N'铝型材抓取机器人1200', 'SCHNEIDER', 'TM241CEC24R',   'CP02')

INSERT INTO Mes_PLC_Parameters (PLCID, ParamName, ParamValue, ParamType, ItemNumber) VALUES
(1, 'mx2.7', '1', 'BOOL', ''),
(1, 'mx3.0', '0', 'BOOL', ''),
(1, 'mx3.1', '0', 'BOOL', ''),
(1, 'md128', '1', 'DWORD', ''),
(1, 'md130', '2', 'DWORD', ''),
(1, 'md132', '3', 'DWORD', ''),
(1, 'md134', '4', 'DWORD', ''),

(2, 'MD600', '4', 'DWORD', ''),
(2, 'MD602', '4', 'DWORD', ''),
(2, 'MD604', '4', 'DWORD', ''),
(2, 'MD606', '4', 'DWORD', ''),
(2, 'MD608', '4', 'DWORD', ''),
(2, 'MD610', '4', 'DWORD', ''),
(2, 'MD612', '4', 'DWORD', ''),
(2, 'MD614', '4', 'DWORD', '')
*/




/****** Script for SelectTopNRows command from SSMS  ******/
insert into [MFG_WO_List]
(
       [ErpWorkOrderNumber]      
      ,[ErpGoodsCode]            
      ,[ErpGoodsDsca]            
      ,[ErpPlanQty]              
      ,[ErpPlanCreateTime]       
      ,[ErpPlanStartTime]        
      ,[ErpPlanFinishTime]       
      ,[ErpPlanReleaseTime]      
      ,[ErpWorkGroup]            
      ,[ErpOrderType]            
      ,[ErpOrderStatus]          
      ,[ErpOBJNR]                
      ,[ErpZTYPE]                
      ,[MesInturnNumber]
      ,[MesPlanQty]
      ,[MesPlanStartTime]
      ,[MesPlanFinishTime]
      ,[MesCostTime]
      ,[MesUnitCostTime]
  ) 
  select 
       [AUFNR]
      ,[MATNR]
      ,[MAKTX]
      ,[GAMNG]
      ,[ERDAT]
      ,[GSTRP]
      ,[GLTRP]
      ,[FTRMI]
      ,[WERKS]
      ,[AUART]
      ,[TXT30]
      ,[OBJNR]
      ,[ZTYPE]
      ,1
      ,[GAMNG]
      ,[GSTRP]
      ,[GLTRP]
      ,[GAMNG]*2
      ,2
      from [ERP_WO_List]



