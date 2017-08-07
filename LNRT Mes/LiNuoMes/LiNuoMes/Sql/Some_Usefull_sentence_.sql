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

--select * from Mes_PLC_TagList where [����ģ��] ='��������'
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
ISNULL([TagList].[��ƷA����ֵ(ParaValueA)], '')  ParamValue, 
TagList.OPCType ParamType, 
[TagList].[I/OType] OperateType, 
TagList.TagName ParamDsca,
CASE TagList.[����ģ��] 
    WHEN '��������' THEN [����ֵ˵����ValueInf��]
    ELSE ''
END ItemNumber, 
CASE TagList.[����ģ��] 
    WHEN '��������' THEN [��ƷA����ֵ(ParaValueA)]
    ELSE ''
END ProcessCode,
CASE TagList.[����ģ��] 
    WHEN '�����ɷ�'    THEN 'VS'
    WHEN '��������'    THEN 'MT'
    WHEN '��ʾ'        THEN 'NA'
    WHEN 'RFID����⵽λ��'     THEN 'RT'
    WHEN '����'     THEN 'AT'
    WHEN '����'     THEN 'NA'
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
UPDATE MES_PLC_Parameters SET ApplModel = 'QS' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE [����ֵ˵����ValueInf��] ='�涩���仯');
UPDATE MES_PLC_Parameters SET ApplModel = 'NA' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE [����ֵ˵����ValueInf��] ='����ȡ������');
UPDATE MES_PLC_Parameters SET ApplModel = 'CS' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '������Ʒ����');
UPDATE MES_PLC_Parameters SET ApplModel = 'ET' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '�й�����');
UPDATE MES_PLC_Parameters SET ApplModel = 'QT' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname LIKE '�������%');
*/
--truncate table Mes_Threshold_List;
INSERT INTO
 Mes_Threshold_List (MaxPullQty, MinTrigQty, ItemNumber, ProcessCode, UOM, ItemName)
values
(100,30,'2710001085','2010','EA','����п�� 1945*945*0.35'),
(100,30,'2710001075','2040','EA','���� L=10MM'),
(100,30,'2710001068','2040','EA','���±߿�LXCP-89 2000mm 6063-T5'),
(100,30,'2710001071','2040','EA','�ұ߿�LXCP-89 1000mm 6063-T5��Բ�ף�'),
(100,30,'2710001072','2040','EA','��߿�LXCP-89 1000mm 6063-T5���޿ף�'),
(100,30,'3110000230','2080','KG','ƽ�����ܷ⽺(��ɫ-270kg/Ͱ��'),
(100,30,'3050000094','2090','EA','���������� �̱����ұ��� �޿�985*66*18'),
(100,30,'3050000095','2090','EA','���������� �̱����ұ��� �п�985*66*18'),
(100,30,'3050000096','2090','EA','���������� ���߱���1952*66*18'),
(100,30,'3050000053','2090','EA','���������� �ײ�����1948*948*35'),
(100,30,'3070100599','2090','EA','��о�̶����� ���ɸ�˿��1.0mm'),
(100,30,'3070400373','2090','EA','�ܷ�Ȧ �������� ��ɫ�� ��22 ��8.5mm ����Ӳ��50����60��'),
(100,30,'3110000052','2090','EA','��ǩ PET75*50mm'),
(100,30,'3070800393','3020','EA','���� ˿ӡ�Ƕ�Ĥ�������ײ��Ƹֻ� 1972*972*3.2 ͸���ʡ�91.75%'),
(100,30,'2710001073','3030','EA','����ѹ��LXCP-90 2000mm 6063-T5'),
(100,30,'2710001074','3030','EA','����ѹ��LXCP-90 1000mm 6063-T5'),
(100,30,'3070400374','3030','EA','��˿ñ ��ɫ�𽺦�23*16*1.5 ����Ӳ��50����60��'),
(100,30,'3070400265','3030','EA','�ܷ�Ȧ Բ�� ��ɫ�� �ھ���22���23 ��11mm ����Ӳ��50����60��'),
(100,30,'3080401085','3030','EA','�ϸ�֤ ƽ�弯����'),
(100,30,'3110000126','3030','EA','��ǩ PET40*100mm'),
(100,30,'3080401084','3030','EA','���� ��˿����ִ�ճ��78mm*18mm'),
(100,30,'3110000220','3080','KG','PE������Ĥ ��0.07*��1344*C PEĤ����25Kg/��'),
(100,30,'3110000005','3090','M','�ƽ��� 60mm*100��'),
(100,30,'3080200170','3090','EA','��ĭ��ͷ EPS(165+5+130)*80*40ƽ�弯������'),
(100,30,'3110000213','3090','KG','�����PP12010J'),
(100,30,'3080101573','3090','EA','ֽ��BD-2.5 ƽ�弯������װ�� �⾶1015*300*95 S0.9'),
(100,30,'3030200745','3090','KG','ͭ�� TP2�̹� ��22*0.6*C'),
(100,30,'3070100764','1010','EA','ͭ��ͷ ���ӽ�ͷHPb59-1 ��55mm ��25�������ȿ� G1/2��˿ƽ��'),
(100,30,'3110000215','1010','KG','����˿��1.8��AG7%������˿��'),
(100,30,'3030200849','1020','KG','��ͭ�̹� ��10*0.45'),
(100,30,'3110000216','1020','KG','����˿��1��AG5%������˿��'),
(100,30,'3110000227','1020','KG','ú��50KG'),
(100,30,'3110000063','1020','KG','����'),
(100,30,'3020000218','1080','EA','���Ȱ� ĤHG 1945*945*0.3 ����92% ��h(80��)��10%');


--truncate table mes_process_list;
insert into Mes_Process_List ( InturnNumber, ProcessCode, AbnormalEnable, AbnormalRegion, ProcessName, ProcessDsca) values
(10,   '1010',0, 1, '22*0.6ͭ�ܼӹ�','22*0.6ͭ�ܼӹ�'),
(20,   '1020',0, 1, '10*0.45ͭ�ܼӹ�','10*0.45ͭ�ܼӹ�'),
(30,   '1030',0, 1, '����ǥ��','����ǥ��'),
(40,   '1040',0, 1, 'ͭ������','ͭ������'),
(50,   '1050',0, 1, 'ͭ��ѹ��','ͭ��ѹ��'),
(60,   '1060',1, 1, 'ͭ�������Լ��','ͭ�������Լ��'),
(70,   '1070',0, 2, '���Ȱ�����','���Ȱ�����'),
(80,   '1080',0, 2, '���⺸','���⺸'),
(90,   '1090',1, 2, '��о�����Լ��','��о�����Լ��'),
(100,  '2010',0, 3, '�װ�����','�װ�����'),
(110,  '2020',0, 3, '����ӹ�','����ӹ�'),
(120,  '2030',0, 3, '���Ͳļӹ�','���Ͳļӹ�'),
(130,  '2040',0, 3, 'Ԥ���','Ԥ���'),
(140,  '2050',0, 3, '���','���'),
(150,  '2060',0, 3, '���߱���ѹ��','���߱���ѹ��'),
(160,  '2070',0, 3, '�̱߱���ѹ��','�̱߱���ѹ��'),
(170,  '2080',0, 3, '�߿�Ϳ��','�߿�Ϳ��'),
(180,  '2090',0, 3, '��װ�ײ�������','��װ�ײ�������'),
(190,  '2100',0, 3, '�߿��оװ��','�߿��оװ��'),
(200,  '3010',0, 3, '������Ϳ��','������Ϳ��'),
(210,  '3020',0, 3, '�����尲װ','�����尲װ'),
(220,  '3030',0, 3, 'Ԥװѹ��','Ԥװѹ��'),
(230,  '3040',0, 3, '����ѹ��','����ѹ��'),
(240,  '3050',1, 3, 'MES������','MES������'),
(250,  '3060',0, 3, 'PET����','PET����'),
(260,  '3070',0, 3, '���','���'),
(270,  '3080',0, 3, '����','����'),
(280,  '3090',0, 3, '��Ʒ��װ','��Ʒ��װ'),
(290,  '3100',0, 3, '���','���'),
(300,  '3110',0, 3, '���','���');



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

    -- ����PLC��ͳ�Ƴ����İ��Ʒ����
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

    --���PLC����
        INSERT INTO Mes_PLC_List (  GoodsCode,           PLCName,  PLCType,   PLCModel, PLCCabinet,  UpdateUser )
                           VALUES( '000000002120360056', @CP,     'SIEMENS', 'SMT200', @LN,         N'TEST'    )

    --��ȡ���һ���ող����¼��ID  (�����ӵ�,����������֮�ڵ�����IDֵ)
        SELECT @TT = SCOPE_IDENTITY()

    --ÿ��PLC�����в���������һ��
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
 ����ַ�����������:��ʼ
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

/*����ַ�����������: ����*/

SELECT * FROM MES_PLC_LIST;
SELECT * FROM Mes_PLC_Parameters;

update mes_plc_parameters set ParamValue = id;
--UPDATE Mes_PLC_Parameters SET ParamName = UPPER(PARAMNAME) WHERE PLCID=2
--UPDATE Mes_PLC_Parameters SET OperateType = 'W' WHERE PLCID=1 AND ParamType='BOOL';
/*
INSERT INTO MES_PLC_LIST (GoodsCode, PLCNAME, PLCType, PLCModel, PLCCABINET) VALUES
('ABCD0', N'�װ�����ֱ������',     'SIEMENS',   'SMART200 ST30', 'CP01'),
('EFGH',  N'���Ͳ�ץȡ������1200', 'SCHNEIDER', 'TM241CEC24R',   'CP02')

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



