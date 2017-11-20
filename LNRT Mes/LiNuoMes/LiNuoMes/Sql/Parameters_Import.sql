--select * from Mes_PLC_TagList where [����ģ��] ='��������'
--select * from Mes_Plc_TagList where [��ƷA����ֵ(ParaValueA)] is not null;
--select * from Mes_Plc_TagList where [��ƷB����ֵ(ParaValueB)] is not null;
--SELECT * FROM Mes_PLC_Parameters WHERE  ApplModel = 'CS'
--ProcessCode <> '' AND
/*

----TRUNCATE TABLE [Mes_PLC_TagList];

DELETE FROM Mes_PLC_Parameters WHERE PLCID IN (SELECT ID FROM Mes_PLC_List WHERE GoodsCode IN ('0000000000'));
DELETE FROM MES_PLC_LIST WHERE GoodsCode IN ('0000000000');

UPDATE Mes_Plc_TagList set PlcCabinet  =  left(tag, patindex('%[._]%',tag) - 1);

INSERT INTO Mes_PLC_List (GoodsCode, PLCName, PLCCode, PLCType, PLCModel, PLCCabinet) SELECT DISTINCT '0000000000' GoodsCode, DeviceName PLCName, DeviceCode PLCCode, PLCBrand PLCType, PlcModel PlcModel, PLCCabinet PLCCabinet FROM Mes_PLC_TagList ORDER BY PLCCODE;

INSERT INTO Mes_PLC_Parameters (PLCID, ParamName, ParamValue, ParamType, OperateType, ParamDsca, ItemNumber, ProcessCode, ApplModel)
SELECT 
    PLC.ID                                          PLCID, 
    TagList.Tag                                     ParamName, 
    CASE TagList.[����ģ��] 
        WHEN '��������' THEN [��ƷB����ֵ(ParaValueB)]
        ELSE ISNULL([TagList].[��ƷA����ֵ(ParaValueA)], '')
    END                                             ParamValue, 
    TagList.OPCType                                 ParamType, 
    [TagList].[I/OType]                             OperateType, 
    TagList.TagName                                 ParamDsca,
    CASE TagList.[����ģ��] 
        WHEN '��������' THEN [����ֵ˵����ValueInf��]
        ELSE ''
    END                                             ItemNumber, 
    CASE TagList.[����ģ��] 
        WHEN '��������' THEN [��ƷB����ֵ(ParaValueB)]
        ELSE ''
    END                                             ProcessCode,
    CASE TagList.[����ģ��] 
        WHEN '�����ɷ�'        THEN 'VS'
        WHEN '��������'        THEN 'MT'
        WHEN '��ʾ'            THEN 'NA'
        WHEN 'RFID����⵽λ��' THEN 'RT'
        WHEN '����'            THEN 'AT'
        WHEN '����'            THEN 'NA'
        ELSE                       'NA'
    END                                              ApplModel
FROM Mes_PLC_TagList TagList,
     Mes_PLC_List  PLC
WHERE 
    TagList.DeviceCode = PLC.PLCCode 
AND TagList.PlcCabinet = PLC.PlcCabinet 
AND PLC.GoodsCode      = '0000000000'
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
UPDATE MES_PLC_LIST SET ProcessCode = '2080' where plccode in ('RP02','CP06');
UPDATE MES_PLC_LIST SET ProcessCode = '2090' where plccode in ('CP08','RP02');
UPDATE MES_PLC_LIST SET ProcessCode = '3010' where plccode in ('RP03','CP09');
UPDATE MES_PLC_LIST SET ProcessCode = '3020' where plccode in ('CP11');
UPDATE MES_PLC_LIST SET ProcessCode = '3050' where plccode in ('CP12', 'CP13');
UPDATE MES_PLC_LIST SET ProcessCode = '3070' where plccode in ('CP101');
UPDATE MES_PLC_LIST SET ProcessCode = '3110' where plccode in ('CP14');

UPDATE MES_PLC_Parameters 
SET 
    MES_PLC_Parameters.ProcessCode = PRO.ProcessCode 
FROM 
    [dbo].[Mes_Process_List] AS PRO
WHERE 
    MES_PLC_Parameters.ApplModel   = 'MT'
AND MES_PLC_Parameters.ProcessCode = PRO.ProcessName;

UPDATE MES_PLC_Parameters SET OperateCommand = 'WRITE' WHERE OperateType = 'W' OR OperateType = 'RW';
UPDATE MES_PLC_Parameters SET ApplModel      = 'QS' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE [����ֵ˵����ValueInf��] ='�涩���仯');
UPDATE MES_PLC_Parameters SET ApplModel      = 'NA' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE [����ֵ˵����ValueInf��] ='����ȡ������');
UPDATE MES_PLC_Parameters SET ApplModel      = 'CS' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '������Ʒ����');
UPDATE MES_PLC_Parameters SET ApplModel      = 'CT' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '������ɷ���');
UPDATE MES_PLC_Parameters SET ApplModel      = 'ET' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname = '�й�����');
UPDATE MES_PLC_Parameters SET ApplModel      = 'QT' WHERE [ParamName] IN (SELECT TAG FROM Mes_PLC_TagList WHERE tagname LIKE '�������%');

UPDATE Mes_PLC_Parameters
SET 
    ProcessCode = PLC.ProcessCode
FROM 
    Mes_PLC_Parameters PAM
   ,Mes_PLC_List plc
WHERE 
PAM.PLCID = PLC.ID
AND GOODSCODE = '0000000000'
AND APPLMODEL IN ('CS','QT')

*/